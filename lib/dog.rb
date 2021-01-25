class Dog
    
    def initialize(attributes)
        self.class.attr_accessor(:id)
        @id=nil
        attributes.each do |key, value|
            #binding.pry
            self.class.attr_accessor(key)
            self.send(("#{key}="),value)
        end
    end

    def self.drop_table
        sql= "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end


    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, name TEXT,
        breed TEXT)
        SQL
        
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed) 
          VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        attributes={:id => row[0], :name => row[1], :breed => row[2]}
        dog = self.new(attributes)
        dog
    end

    def self.find_by_id(search_id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql,search_id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(attributes)
        sql = "select * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, attributes[:name],attributes[:breed])
         if !dog.empty?
 
            dog_data = dog[0]
            dog = self.new_from_db(dog_data)
        else
            dog = self.create(attributes)
        end
        dog
    end

    def self.find_by_name(search_name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql,search_name).map {|row| self.new_from_db(row)}.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end