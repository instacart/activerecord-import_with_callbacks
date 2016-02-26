require 'active_record'
require 'activerecord-import/base'
require 'fiber'

module ActiveRecord
  module ImportWithCallbacks
    Result = Class.new(ActiveRecord::Import::Result)
    DEFAULT_BATCH_SIZE = 100
    DEFAULT_RECURSIVE = true
    extend ActiveSupport::Concern

    # Insert multiple records in batches with callbacks
    #
    # @param [Array<ActiveRecord::Base>] records
    # @param [Hash] options
    # @option options [Boolean] :validate Default: true
    # @option options [Array, Hash] :on_duplicate_key_update
    # @option options [Array<ActiveRecord::Base>] :synchronize Synchronize
    #   existing records in memory with updates from the import
    # @option options [Boolan] :timestamps
    # @option options [Boolan] :recursive Import all autosave associations
    # @option options [Integer] :batch_size Default: 100
    # @return [ActiveRecord::Import::Result]
    def import_with_callbacks(*args)
      options = args.extract_options!
      records = args.pop
      options[:batch_size] = DEFAULT_BATCH_SIZE unless options.key?(:batch_size)
      options[:recursive] = DEFAULT_RECURSIVE unless options.key?(:recursive)
      import_in_transaction(records, options)
    end

    private

    def import_in_transaction(records, options)
      Base.transaction do
        import_in_batches(records, options)
      end
    end

    def import_in_batches(records, options)
      results = records.each_slice(options.fetch(:batch_size)).map do |slice|
        slice.each { |record| record.send(:remember_transaction_record_state) }
        with_callbacks(slice) do
          import(slice, options)
        end
      end
      merge_results(results)
    end

    def with_callbacks(records)
      run_callbacks(records, :before, :save)
      around_save_fibers = split_callbacks(records, :save)
      run_callbacks(records, :before, :create)
      around_create_fibers = split_callbacks(records, :create)
      result = yield
      # Execute the "after" part of around_create callbacks
      around_create_fibers.select(&:alive?).each(&:resume)
      run_callbacks(records, :after, :create)
      # Execute the "after" part of around_save callbacks
      around_save_fibers.select(&:alive?).each(&:resume)
      run_callbacks(records, :after, :save, :commit)
      result
    end

    def run_callbacks(records, before_or_after, *callbacks)
      callbacks.each do |callback|
        records.each do |record|
          chain = build_callback_chain(record, before_or_after, callback)
          run_chain(record, chain)
        end
      end
    end

    def split_callbacks(records, callback)
      fibers = records.map do |record|
        chain = build_callback_chain(record, :around, callback)
        split_chain(record, chain)
      end
      # Execute the before part of around_* callbacks and pause at the yield
      fibers.each(&:resume)
    end

    def build_callback_chain(record, before_after_or_around, callback)
      chain = ActiveSupport::Callbacks::CallbackChain.new(callback, {})
      callbacks = record.public_send(:"_#{callback}_callbacks")
      append_callbacks_to_chain(callbacks, chain, before_after_or_around)
      chain
    end

    def append_callbacks_to_chain(callbacks, chain, kind)
      callbacks.select { |cb| cb.kind.equal?(kind) }.each do |callback|
        next if callback.filter.to_s.start_with?('autosave_')
        chain.append(callback)
      end
    end

    def run_chain(m, chain)
      runner = chain.compile
      e = ActiveSupport::Callbacks::Filters::Environment.new(m, false)
      runner.call(e)
    end

    def split_chain(m, chain)
      runner = chain.compile
      p = proc { Fiber.yield }
      e = ActiveSupport::Callbacks::Filters::Environment.new(m, false, nil, p)
      Fiber.new { runner.call(e) }
    end

    def merge_results(results)
      failed_instances = results.inject([]) { |a, e| a + e.failed_instances }
      num_inserts = results.inject(0) { |a, e| a + e.num_inserts }
      ids = results.inject([]) { |a, e| a + e.ids }
      Result.new(failed_instances, num_inserts, ids)
    end
  end

  Base.extend(ActiveRecord::ImportWithCallbacks)
end
