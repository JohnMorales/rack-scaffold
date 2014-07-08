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
      expect(artist).not_to be_nil
      expect(artist.name).to eq(artist_attrs[:name])
      expect(artist.artistDescription).to eq(artist_attrs[:artistDescription])
    end

    it 'should update the artist successfully' do
      post '/artists', get_artist_attributes
      put '/artists/1/', :name => "Barbara"
      artist = @adapter::Artist.first
      expect(artist.name).to eq "Barbara"
    end

    it 'should delete the artist successfully' do
      artist_attrs = get_artist_attributes
      post '/artists', artist_attrs
      artist = @adapter::Artist.first(:name => artist_attrs[:name])
      expect(artist).not_to be_nil
      delete "/artists/#{artist.id}"
      artist = @adapter::Artist.first(:name => artist_attrs[:name])
      expect(artist).to be_nil
    end
  end

  describe 'api /artists endpoint' do
    it 'should return an empty artist list' do 
      get '/artists'
      expected = { artists:[] }
      expect(last_response.body).to eq(expected.to_json)
    end

    it 'should return the artist inserted' do
      post '/artists', get_artist_attributes
      expected = { :artist => @adapter::Artist.first }
      expect(last_response.body).to eq expected.to_json
    end

    it 'should return an artist list' do
      post '/artists', get_artist_attributes
      get '/artists'
      expected = { :artists => @adapter::Artist.all }
      expect(last_response.body).to eq(expected.to_json)
    end
    
    it 'should return an artist list when there is a trailing slash' do
      post '/artists', get_artist_attributes
      get '/artists/'
      expected = { :artists => @adapter::Artist.all }
      expect(last_response.body).to eq(expected.to_json)
    end

    it 'should return one artist entity' do
      post '/artists', get_artist_attributes
      get '/artists/1'
      expected = { :artist => @adapter::Artist.first }
      expect(last_response.body).to eq expected.to_json
    end
  end

  describe 'get one to many relations' do 
    it 'should return one to many relations' do
      post '/artists', get_artist_attributes
      artist = @adapter::Artist.first
      post '/songs', { title: "Black Trombone", artist_id: artist.id }
      song = @adapter::Song.first
      expected = { :song => song }
      expect(last_response.body).to eq expected.to_json
      get "/artists/#{artist.id}/songs"
      expected = { :songs => [ song ] }
      expect(last_response.body).to eq expected.to_json
    end
  end
end
