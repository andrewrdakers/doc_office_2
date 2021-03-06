class Patient
  attr_accessor :name, :birthday, :id

  def initialize(attributes)
    @name = attributes['name']
    @birthday = attributes['birthday']
    @id = attributes['id'].to_i
  end

  def self.all
    patients = []
    result = DB.exec('SELECT * FROM patients')
    result.each do |patient|
      name = patient['name']
      birthday = patient['birthday']
      id = patient['id'].to_i
      patients << Patient.new({'name' => name, 'birthday' => birthday,
                              'id' => id})
    end
    patients
  end

  def ==(another_patient)
    @name == another_patient.name && @id == another_patient.id
  end

  def save
    result = DB.exec("INSERT INTO patients (name, birthday) VALUES
                    ('#{@name}', '#{@birthday}') RETURNING id;")
    @id = result.first['id'].to_i
  end

  def assign_doctor(doctor)
    DB.exec("INSERT INTO doctor_patient (patient_id, doctor_id) VALUES (#{@id}, #{doctor.id});")
  end

  def doctors
    doctors = []
    result = DB.exec("SELECT doctor_id FROM doctor_patient WHERE patient_id = '#{@id}';")
    result.each do |result|
      doctor_id = result['doctor_id'].to_i
      doctor_name = DB.exec("SELECT * FROM doctors WHERE id = #{doctor_id};").first['name']
      doctors << Doctor.new({'name' => doctor_name, 'id' => doctor_id})
    end
    doctors
  end

  def update_patient(new_info)
    DB.exec("UPDATE patients SET name = '#{new_info.name}' WHERE id = #{@id};")
    DB.exec("UPDATE patients SET birthday = '#{new_info.birthday}' WHERE id = #{@id};")
    @name = new_info.name
    @birthday = new_info.birthday
  end

  def delete_patient!
    DB.exec("DELETE FROM patients WHERE id = #{@id}")
  end
end
