class Student

  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography

  # instance has an id, name, tagline, github username, twitter handle, blog_url, image_url, biography 

  def self.create_table # Student.create_table means it is a class method
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        tagline TEXT,
        github TEXT,
        twitter TEXT,
        blog_url TEXT,
        image_url TEXT,
        biography TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end # end create_table

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students 
    SQL

    DB[:conn].execute(sql)
  end # end drop_table

  def insert # 7 values
    sql = <<-SQL
      INSERT INTO students (name,tagline,github,twitter,blog_url,image_url,biography) 
      VALUES (?,?,?,?,?,?,?)
    SQL

    DB[:conn].execute(sql, attribute_values)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end # end insert

  def self.new_from_db(row) # when passed a row of attributes, which includes id
    self.new.tap do |s|
      s.id = row[0]
      s.name =  row[1]
      s.tagline = row[2]
      s.github =  row[3]
      s.twitter =  row[4]
      s.blog_url =  row[5]
      s.image_url = row[6]
      s.biography = row[7]
    end # end tap block
  end # end new_from_db

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # helper method
  def attribute_values
    [name, tagline, github, twitter, blog_url, image_url, biography]
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?,tagline = ?,github = ?,twitter = ?,blog_url = ?,image_url = ?,biography = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, attribute_values, id)
  end # end update

  def persisted? # helper method for save
    !!self.id # double negation turns into true
  end # end persisted

  def save
    persisted? ? update : insert
  end # end save
end # class