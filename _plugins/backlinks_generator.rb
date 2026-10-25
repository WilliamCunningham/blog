# frozen_string_literal: true
# class BacklinksGenerator < Jekyll::Generator
#   def generate(site)

#     notes = site.collections['notes'].docs

#     # Create new files for [[ ]] words
#     notes.each do |current_note|    
#       links = current_note.content.scan(/(?<=\[\[).*?(?=\]\])/)
      
#       links.each do |link|
#         slug = link.gsub(" ", "-").downcase

#         if !File.file?("_notes/" + slug + ".md")
#           new_file = File.new("_notes/" + slug + ".md", "w+")
#           new_file.puts("---\ntitle: " + link + "\n---")
#           new_file.close
#         end
#       end
#     end

#     # Convert [[ ]] words to markdown
#     Dir["*/*.md"].each do |note|
#       text = File.read(note)
#       links = text.scan(/(?<=\[\[).*?(?=\]\])/)
      
#       links.each do |link|
#         slug = link.gsub(" ", "-").downcase

#         new_contents = text.gsub(/\[\[#{link}\]\]/i, "[#{link}](/#{slug}){: .link-internal}")

#         File.open(note, "w") { |file| file.puts new_contents }
#       end
#     end 

#     # Populate backlinks section
#     notes.each do |current_note|
#       backlinks = notes.filter do |note|
#         note.content.include?(current_note.url)
#       end

#       current_note.data['backlinks'] = backlinks
#     end

#   end
# end
