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
      dog = Dog.new(name: given_attributes[:name], breed: given_attributes[:breed]).save
      dog
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
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", given_value[:name], given_value[:breed])

    if dog.empty?
      dog =  Dog.create(name: given_value[:name], breed: given_value[:breed])
    else
      new_dog = dog[0]
      dog = Dog.new(id: new_dog[0],name: new_dog[1],breed: new_dog[2])
    end
     dog
  end

  def self.new_from_db(given_value)
      new_dog = Dog.new(id: given_value[0].to_i, name: given_value[1], breed: given_value[2])
      new_dog
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    Dog.new(id: dog[0][0],name: dog[0][1], breed: dog[0][2])
  end

  def update
    update_sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(update_sql, self.name, self.breed, self.id)
  end
end
