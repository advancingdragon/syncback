require 'syncback'

Shoes.app(:title => "Synchronize",
          :width => 700,
          :height => 300,
          :resizable => true) do

  ## GUI code

  def add_folder_pair
    @main_stack.before(@footer) do
      this_flow = flow do
        linked_folder_1 = edit_line(:height => 30)
        button("Browse...") { linked_folder_1.text = ask_open_folder }
        linked_folder_2 = edit_line(:height => 30)
        button("Browse...") { linked_folder_2.text = ask_open_folder }
        button("Remove") { this_flow.remove }
      end
    end
  end

  def get_linked_folders
    linked_folders = []
    @main_stack.contents.each do |a_flow|
      next if a_flow == @header or a_flow == @footer
      elems = a_flow.contents
      linked_folders << SyncBack::FolderPair.new(elems[0].text, elems[2].text) # dirty hack
    end
    return linked_folders
  end

  # Main description of window
  @main_stack = stack do
    @header = flow do
      para("Select the folders that you would like to synchronize.")
    end
    @footer = flow do
      button("Add") { add_folder_pair }
      button("Synchronize") do
        folder_pairs = get_linked_folders
        diff_1_2, diff_2_1 = SyncBack.synchronize(folder_pairs[0]) do |entry_index, entries, src, dest|
          @progress.contents[0].text = entry_index.to_s + " out of " + entries.to_s + " files copied."
          @progress.contents[1].text = "From " + src
          @progress.contents[2].text = "to " + dest
        end
      end
    end
    @progress = flow do
      para ""
      para ""
      para ""
    end
  end

  add_folder_pair
end
