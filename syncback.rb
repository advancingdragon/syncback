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

  # NOTE: This function only looks at filenames, not at the files'
  # content. It assumes that two files/folders with the same name and
  # relative path are the same.
  #
  # Finds the differences between two folders.
  def self.diff(folder_pair)
    folder_1_entries = Dir.entries(folder_pair.folder_1)
    folder_2_entries = Dir.entries(folder_pair.folder_2)

    diff_1_2 = folder_1_entries - folder_2_entries
    diff_2_1 = folder_2_entries - folder_1_entries
    common = folder_1_entries & folder_2_entries

    # filter out non-directories and the . and .. directories
    common.delete_if do |entry|
      entry == "." or
      entry == ".." or
      not File.directory?(folder_pair.folder_1 + "/" + entry) or
      not File.directory?(folder_pair.folder_2 + "/" + entry)
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
    
    # keep count of completed files
    entry_index = 1
    entries = diff_1_2.length + diff_2_1.length

    # copy 1 to 2
    diff_1_2.each do |entry|
      src = folder_pair.folder_1 + "/" + entry
      dest = folder_pair.folder_2 + "/" + entry
      FileUtils.cp_r(src, dest)
      # report to GUI
      yield entry_index, entries, src, dest
      entry_index += 1
    end

    # copy 2 to 1
    diff_2_1.each do |entry|
      src = folder_pair.folder_2 + "/" + entry
      dest = folder_pair.folder_1 + "/" + entry
      FileUtils.cp_r(src, dest)
      # report to GUI
      yield entry_index, entries, src, dest
      entry_index += 1
    end
  end
end
