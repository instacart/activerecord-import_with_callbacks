require 'active_record'
require 'activerecord-import/base'
require 'fiber'

module ActiveRecord
  module ImportWithCallbacks
    extend ActiveSupport::Concern
    def import_with_callbacks(*args)
      import(*args)
    end
  end

  Base.extend(ActiveRecord::ImportWithCallbacks)
end
