require 'spec_helper'

describe ActiveRecord::ImportWithCallbacks do
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
  end

  it 'returns ids for successfully imported records' do
    brand = Brand.new(name: 'Brand')
    results = Brand.import_with_callbacks([brand])
    expect(results.failed_instances).to be_empty
    expect(results.num_inserts).to eq(1)
    expect(results.ids.first.to_i).to eq(brand.id)
  end
end
