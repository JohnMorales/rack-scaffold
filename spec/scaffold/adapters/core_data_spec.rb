require "spec_helper"

# Add an accessor to access the @adaptor attribute
module Rack
  class Scaffold
    attr_reader :adapter
  end
end

RSpec.configure do |config|
  def app
    @scaffold_app = Rack::Scaffold.new model: './example/Example.xcdatamodeld'
    @adapter = @scaffold_app.adapter
    Rack::Lint.new(@scaffold_app)
  end
end

describe Rack::Scaffold::Adapters::CoreData do
  def get_artist_attributes
    { :name => 'Serge Gainsbourg', :artistDescription => 'Renowned for his often provocative and scandalous releases' }
  end

  describe 'Create/Update/Delete operations' do
    it 'should create the artist successfully' do
      artist_attrs = get_artist_attributes
      post '/artists', artist_attrs
      artist = @adapter::Artist.first
      artist.should_not be_nil
      artist.name.should == artist_attrs[:name]
      artist.artistDescription.should == artist_attrs[:artistDescription]
    end

    it 'should update the artist successfully' do
      post '/artists', get_artist_attributes
      put '/artists/1/', :name => "Barbara"
      artist = @adapter::Artist.first
      artist.name.should == "Barbara"
    end

    it 'should delete the artist successfully' do
      artist_attrs = get_artist_attributes
      post '/artists', artist_attrs
      artist = @adapter::Artist.first(:name => artist_attrs[:name])
      artist.should_not be_nil
      delete "/artists/#{artist.id}"
      artist = @adapter::Artist.first(:name => artist_attrs[:name])
      artist.should be_nil
    end
  end

  describe 'api /artists endpoint' do
    it 'should return an empty artist list' do 
      get '/artists'
      expected = { artists:[] }
      last_response.body.should == expected.to_json
    end

    it 'should return the artist inserted' do
      post '/artists', get_artist_attributes
      expected = { :artist => @adapter::Artist.first }
      last_response.body.should == expected.to_json
    end

    it 'should return an artist list' do
      post '/artists', get_artist_attributes
      get '/artists'
      expected = { :artists => @adapter::Artist.all }
      last_response.body.should == expected.to_json
    end

    it 'should return one artist entity' do
      post '/artists', get_artist_attributes
      get '/artists/1'
      expected = { :artist => @adapter::Artist.first }
      last_response.body.should == expected.to_json
    end
  end
end