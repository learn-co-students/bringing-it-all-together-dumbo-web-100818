class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs;'
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    rows = DB[:conn].execute(sql, id).flatten
    id_num = rows[0]
    dog_name = rows[1]
    breed_name = rows[2]
    dog = Dog.new(name: dog_name, id: id_num, breed: breed_name)
  end

  def self.find_or_create_by(name:, breed:)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?;'
    rows = DB[:conn].execute(sql, name, breed).flatten
    if rows.size > 0
      id_num = rows[0]
      dog_name = rows[1]
      breed_name = rows[2]
      dog = Dog.new(name: dog_name, id: id_num, breed: breed_name)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ?;'
    rows = DB[:conn].execute(sql, name).flatten
    id_num = rows[0]
    dog_name = rows[1]
    breed_name = rows[2]
    dog = Dog.new(id: id_num, name: dog_name, breed: breed_name)
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if id == nil
      sql = 'INSERT INTO dogs (name, breed) VALUES (?,?);'
      DB[:conn].execute(sql, self.name, self.breed)
      getter = 'SELECT last_insert_rowid() FROM dogs;'
      got = DB[:conn].execute(getter)
      @id = got[0][0]
    else
      self.update
    end
    self
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?;'
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end







  end
