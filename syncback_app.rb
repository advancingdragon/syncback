require 'syncback'

Shoes.app(:title => "Synchronize",
          :width => 700,
          :height => 300,
          :resizable => true) do

  ## GUI code

  def get_linked_folders
    linked_folders = []
    self.named_contents[:main_stack][:folders].contents.each do |a_flow|
      linked_folders << SyncBack::FolderPair.new(a_flow[:linked_folder_1].text, 
                                                 a_flow[:linked_folder_2].text)
    end
    return linked_folders
  end

  # Main description of window
  stack do
    flow do
      para "Select the folders that you would like to synchronize."
    end

    stack do
    end
    name_this :folders

    flow do
      button("Add") do
        canvas[:main_stack][:folders].append do
          this_flow = flow do
            edit_line(:height => 30)
            name_this :linked_folder_1
            button("Browse...") { this_flow[:linked_folder_1].text = ask_open_folder }
            edit_line(:height => 30)
            name_this :linked_folder_2
            button("Browse...") { this_flow[:linked_folder_2].text = ask_open_folder }
            button("Remove") { this_flow.remove }
          end
        end
      end

      button("Synchronize") do
        folder_pairs = get_linked_folders
        folder_pairs.each do |folder_pair|
          SyncBack.synchronize(folder_pair) do |entry_index, entries, src, dest|
            canvas[:main_stack][:progress][:progress_number].text = entry_index.to_s + " of " + entries.to_s + " files copied."
            canvas[:main_stack][:progress].append do
              para src + " copied to " + dest
            end
          end
        end
      end
    end

    stack do
      para ""
      name_this :progress_number
    end
    name_this :progress
  end
  name_this :main_stack

end
