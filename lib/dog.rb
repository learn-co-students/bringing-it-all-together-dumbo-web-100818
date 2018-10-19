  require "pry"
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: , breed: )
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      Dog.new(id: @id, name: name, breed: breed)
  end

  def self.create(given_attributes)
      Dog.new(name: given_attributes[:name], breed: given_attributes[:breed]).save
  end

  def self.find_by_id(id)
      sql = <<-SQL
          SELECT * FROM dogs WHERE id = ?
      SQL

      DB[:conn].execute(sql, id).map do |key|
      return  Dog.new(id: key[0], name: key[1], breed: key[2])
    end
  end

  def self.find_or_create_by(given_value)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",given_value[:name])
    if dog.empty?
      return Dog.create(id: dog[0],name: dog[1],breed: dog[2])
    else
      return  Dog.new(id: dog[0],name: dog[1],breed: dog[2])
    end
  end







end
