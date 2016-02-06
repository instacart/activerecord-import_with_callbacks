require 'active_record'
require 'activerecord-import/base'
require 'fiber'

module ActiveRecord
  module ImportWithCallbacks
    Result = Class.new(ActiveRecord::Import::Result)
    DEFAULT_BATCH_SIZE = 100
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
      import_in_batches(records, options)
    end

    private

    def import_in_batches(records, options)
      results = records.each_slice(options.fetch(:batch_size)).map do |slice|
        import(slice, options)
      end
      merge_results(results)
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
