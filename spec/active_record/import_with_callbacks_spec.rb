require 'spec_helper'

describe ActiveRecord::ImportWithCallbacks do
  let(:brand) { Brand.create(name: 'Brand') }

  let(:product) { Product.new(brand: brand, name: 'Product') }

  it 'has a version number' do
    expect(ActiveRecord::ImportWithCallbacks::VERSION).not_to be nil
  end

  it 'returns an empty results struct when importing zero records' do
    results = Brand.import_with_callbacks([])
    expect(results.failed_instances).to be_empty
    expect(results.num_inserts).to be_zero
    expect(results.ids).to be_empty
  end

  it 'returns failed instances when importing invalid records' do
    brand = Brand.new
    results = Brand.import_with_callbacks([brand])
    expect(results.failed_instances.size).to eq(1)
    expect(results.num_inserts).to be_zero
    expect(results.ids).to be_empty
  end

  it 'imports multiple records with a single insert statement' do
    brands = Array.new(2) { |i| Brand.new(name: "Brand #{i}") }
    result = Brand.import_with_callbacks(brands)
    expect(result.num_inserts).to eq(1)
    expect(result.ids.size).to eq(2)
  end

  it 'batches imports into groups of 100 (by default)' do
    brands = Array.new(101) { |i| Brand.new(name: "Brand #{i}") }
    result = Brand.import_with_callbacks(brands)
    expect(result.num_inserts).to eq(2)
    expect(result.ids.size).to eq(101)
  end

  it 'allows the user to override the default batch size' do
    brands = Array.new(11) { |i| Brand.new(name: "Brand #{i}") }
    result = Brand.import_with_callbacks(brands, batch_size: 5)
    expect(result.num_inserts).to eq(3)
    expect(result.ids.size).to eq(11)
  end

  it 'returns ids for successfully imported records' do
    brand = Brand.new(name: 'Brand')
    results = Brand.import_with_callbacks([brand])
    expect(results.failed_instances).to be_empty
    expect(results.num_inserts).to eq(1)
    expect(results.ids.first.to_i).to eq(brand.id)
  end

  it 'runs before_save callbacks once' do
    expect(product).to receive(:before_save_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs around_save callbacks once' do
    expect(product).to receive(:around_save_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs before_create callbacks once' do
    expect(product).to receive(:before_create_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs around_create callbacks once' do
    expect(product).to receive(:around_create_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs after_save callbacks once' do
    expect(product).to receive(:after_save_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs after_create callbacks once' do
    expect(product).to receive(:after_create_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs after_commit callbacks once' do
    expect(product).to receive(:after_commit_callback).once
    Product.import_with_callbacks([product])
  end

  it 'runs on create after_commit callbacks once' do
    expect(product).to receive(:after_commit_callback_on_create).once
    Product.import_with_callbacks([product])
  end

  it 'does not run on update after_commit callbacks' do
    expect(product).not_to receive(:after_commit_callback_on_update)
    Product.import_with_callbacks([product])
  end

  it 'does not run conditional before_save callbacks' do
    expect(product).not_to receive(:before_save_callback_if_false)
    Product.import_with_callbacks([product])
  end

  it 'does not run conditional before_create callbacks' do
    expect(product).not_to receive(:before_create_callback_if_false)
    Product.import_with_callbacks([product])
  end

  it 'does not run conditional after_save callbacks' do
    expect(product).not_to receive(:after_save_callback_if_false)
    Product.import_with_callbacks([product])
  end

  it 'does not run conditional after_create callbacks' do
    expect(product).not_to receive(:after_create_callback_if_false)
    Product.import_with_callbacks([product])
  end

  it 'does not run conditional after_commit callbacks' do
    expect(product).not_to receive(:after_commit_callback_if_false)
    Product.import_with_callbacks([product])
  end

  it 'runs callbacks in the right order' do
    Product.import_with_callbacks([product])
    expected = %w(before_save_callback
                  before_around_save_callback
                  before_create_callback
                  before_around_create_callback
                  after_around_create_callback
                  after_create_callback
                  after_around_save_callback
                  after_save_callback
                  after_commit_callback_on_create
                  after_commit_callback)
    expect(product.history).to eq(expected)
  end
end
