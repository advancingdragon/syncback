require 'fileutils'

module SyncBack

  class FolderPair
    attr_reader :folder_1
    attr_reader :folder_2

    def initialize(folder_1, folder_2)
      @folder_1 = folder_1
      @folder_2 = folder_2
    end
  end

  # Finds the differences between two folders.
  def self.diff(folder_pair)
    diff_hash = {}
    common = []
    diff_1_2 = []
    diff_2_1 = []

    Dir.foreach(folder_pair.folder_1) do |entry|
      diff_hash[entry] = false
    end
    # find files/subfolders that are in folder 2 but not in folder 1
    Dir.foreach(folder_pair.folder_2) do |entry|
      diff_2_1 << entry if not diff_hash.has_key?(entry)
      diff_hash[entry] = true
    end
    diff_hash.each do |entry, flag|
      # find files/subfolders that are in folder 1 but not in folder 2
      diff_1_2 << entry if not flag
      # find common subfolders
      if flag and 
          File.directory?(folder_pair.folder_1 + "/" + entry) and 
          File.directory?(folder_pair.folder_2 + "/" + entry) and 
          entry != ".." and entry != "." # exclude the . and .. folders
        common << entry 
      end
    end
    
    # recurse in common subfolders
    common.each do |subfolder|
      subfolder_1 = folder_pair.folder_1 + "/" + subfolder
      subfolder_2 = folder_pair.folder_2 + "/" + subfolder
      sub_diff_1_2, sub_diff_2_1 = diff(FolderPair.new(subfolder_1, subfolder_2))
      # if there are differences, add them to "main" diff
      if sub_diff_1_2 != []
        sub_diff_1_2.map! { |entry| subfolder + "/" + entry }
        diff_1_2 += sub_diff_1_2
      end
      if sub_diff_2_1 != []
        sub_diff_2_1.map! { |entry| subfolder + "/" + entry }
        diff_2_1 += sub_diff_2_1
      end
    end
    return diff_1_2, diff_2_1
  end

  # Does the differential copying between the two folders.
  def self.synchronize(folder_pair)
    diff_1_2, diff_2_1 = diff(folder_pair)
    
    # copy 1 to 2
    diff_1_2.each do |entry|
      src = folder_pair.folder_1 + "/" + entry
      dest = folder_pair.folder_2 + "/" + entry
      FileUtils.cp(src, dest)
    end
    # copy 2 to 1
    diff_2_1.each do |entry|
      src = folder_pair.folder_2 + "/" + entry
      dest = folder_pair.folder_1 + "/" + entry
      FileUtils.cp(src, dest)
    end
  end
end
