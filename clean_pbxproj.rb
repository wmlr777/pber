require 'xcodeproj'
project_path = 'pb.xcodeproj'
project = Xcodeproj::Project.open(project_path)

def remove_missing_files(group)
  group.files.each do |file|
    unless File.exist?(file.real_path)
      puts "Removing missing file reference: #{file.path}"
      file.remove_from_project
    end
  end
  group.groups.each do |subgroup|
    remove_missing_files(subgroup)
  end
end

remove_missing_files(project.main_group)
project.save
