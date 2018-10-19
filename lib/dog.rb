class Dog
  @@all = []

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
    @@all << self
  end

  def self.all
    @@all
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |x|
      new_from_db(x)
    end[0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |x|
      new_from_db(x)
    end[0]
  end

  def self.new_from_db(lala)
    id = lala[0]
    name = lala[1]
    breed = lala[2]

    Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name,  breed)
    if !dog.empty?
      doggg = dog[0]
      dog = Dog.new(id: doggg[0], name: doggg[1], breed: doggg[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
 end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end
end
