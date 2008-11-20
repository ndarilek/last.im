class User
  include DataMapper::Resource

  property :id, String, :key => true, :nullable => false
  property :username, String, :nullable => false
  property :password, String, :nullable => false
end
