class Product < ActiveRecord::Base
  FALSE_PROC = proc { false }

  before_save :before_save_callback
  around_save :around_save_callback
  before_create :before_create_callback
  around_create :around_create_callback
  after_create :after_create_callback
  after_save :after_save_callback
  after_commit :after_commit_callback
  after_commit :after_commit_callback_on_create, on: :create
  after_commit :after_commit_callback_on_update, on: :update
  before_save :before_save_callback_if_false, if: FALSE_PROC
  around_save :around_save_callback_if_false, if: FALSE_PROC
  before_create :before_create_callback_if_false, if: FALSE_PROC
  around_create :around_create_callback_if_false, if: FALSE_PROC
  after_create :after_create_callback_if_false, if: FALSE_PROC
  after_save :after_save_callback_if_false, if: FALSE_PROC
  after_commit :after_commit_callback_if_false, if: FALSE_PROC
  belongs_to :brand
  has_many :discounts, as: :discountable
  has_many :items
  validates :name, presence: true
  validates :name, uniqueness: true

  attr_reader :history

  private

  def initialize(*)
    @history = []
    super
  end

  def around_save_callback
    @history << 'before_around_save_callback'
    yield
    @history << 'after_around_save_callback'
  end

  def around_create_callback
    @history << 'before_around_create_callback'
    yield
    @history << 'after_around_create_callback'
  end

  %w(before_save_callback
     before_create_callback
     after_create_callback
     after_save_callback
     after_commit_callback
     after_commit_callback_on_create
     after_commit_callback_on_update
     before_save_callback_if_false
     around_save_callback_if_false
     before_create_callback_if_false
     after_create_callback_if_false
     around_create_callback_if_false
     after_save_callback_if_false
     after_commit_callback_if_false).each do |method|
    define_method(method) do
      @history << method
    end
  end
end
