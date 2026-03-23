require 'xcodeproj'

project_path = 'METIME.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'METIME' }
raise "Target METIME non trovato" unless target

# Trova o crea il gruppo App
app_group = project.main_group.find_subpath('App', false)
raise "Gruppo App non trovato" unless app_group

# Controlla se il file è già presente
already_added = app_group.files.any? { |f| f.path == 'PetColor.swift' }
if already_added
  puts "PetColor.swift già nel progetto."
  exit 0
end

# Aggiungi il file al gruppo
file_ref = app_group.new_reference('PetColor.swift')

# Aggiungi al target
target.source_build_phase.add_file_reference(file_ref)

project.save
puts "PetColor.swift aggiunto al target METIME con successo."
