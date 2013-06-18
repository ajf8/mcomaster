module FileBrowser
 def browse(root)
   queue = Array.new.push(root)
   while !queue.empty?
     filename = queue.pop
     if File.file?(filename)
       yield(filename)
     else
       Dir.new(filename).each do |child|
         unless ['..', '.','.svn'].include? child
           queue.push(filename + "/" + child)
         end
       end
     end
   end
 end
end

class HeadersCheck
 EXT = ['java', 'xml', 'bpel', 'wsdl', 'c', 'cpp', 'js', 'coffee', 'hbs', 'rb' ]

 include FileBrowser

 def check_files(dir, dry_run)
   count = 0
   browse(dir) do |filename|
     if /\.#{EXT.join('$|\.')}$/ =~ filename
       match = nil
       f = File.new(filename)
       # Checking for the Apache header in the 4 first lines
       4.times do
         match ||= (/Licensed to the Apache Software Foundation/ =~
f.readline) rescue nil
           #puts("File #{filename} too short to check.")
       end
       f.close
       unless match
         if dry_run
           puts "Missing header in #{filename}"
         else
           add_header(filename)
         end
         count += 1
       end
     end
   end
   if dry_run
     puts "#{count} files don't have an Apache license header."
   else
     puts "#{count} files have been changed to include the Apache license
header."
   end
 end

 def add_header(filename)
   # Extracting file extension
   ext = /\.([^\.]*)$/.match(filename[1..-1])[1]
   header = HEADERS[ext]
   content = File.new(filename, 'r').read
   if content[0..4] == '<?xml'
     # If the file has a xml header, the license needs to be appended after
     content = content[0..content.index("\n")] + header + content[(
content.index("\n") + 1)..-1]
   else
     content = header + content
   end
   File.new(filename, 'w').write(content)
 end

end

JAVA_HEADER = <<JAVA
/* Copyright 2013 ajf http://github.com/ajf8
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
JAVA

RUBY_HEADER = <<RBHEADER
# Copyright 2013 ajf http://github.com/ajf8
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
RBHEADER

HBS_HEADER = <<HBSHEADER
{{! Copyright 2013 ajf http://github.com/ajf8 }} 
{{! }} 
{{! Licensed under the Apache License, Version 2.0 (the "License"); }} 
{{! you may not use this file except in compliance with the License. }} 
{{! You may obtain a copy of the License at }} 
{{! }} 
{{!     http://www.apache.org/licenses/LICENSE-2.0 }} 
{{! }} 
{{! Unless required by applicable law or agreed to in writing, software }} 
{{! distributed under the License is distributed on an "AS IS" BASIS, }} 
{{! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }} 
{{! See the License for the specific language governing permissions and }} 
{{! limitations under the License. }} 
{{! }} 
HBSHEADER

COFFEE_HEADER = <<COFFEEHEADER
###
 Copyright 2013 ajf http://github.com/ajf8

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###
COFFEEHEADER

XML_HEADER = <<XML
<!--
 ~ Copyright 2013 ajf http://github.com/ajf8
 ~
 ~ Licensed to the Apache Software Foundation (ASF) under one
 ~ or more contributor license agreements.  See the NOTICE file
 ~ distributed with this work for additional information
 ~ regarding copyright ownership.  The ASF licenses this file
 ~ to you under the Apache License, Version 2.0 (the
 ~ "License"); you may not use this file except in compliance
 ~ with the License.  You may obtain a copy of the License at
 ~
 ~    http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~ Unless required by applicable law or agreed to in writing,
 ~ software distributed under the License is distributed on an
 ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 ~ KIND, either express or implied.  See the License for the
 ~ specific language governing permissions and limitations
 ~ under the License.
 -->
XML

HEADERS = {
 'java' => JAVA_HEADER,
 'c' => JAVA_HEADER,
 'cpp' => JAVA_HEADER,
 'coffee' => COFFEE_HEADER,
 'js' => JAVA_HEADER,
 'hbs' => HBS_HEADER,
 'rb' => RUBY_HEADER,
 'xml' => XML_HEADER,
 'bpel' => XML_HEADER,
 'wsdl' => XML_HEADER
}

if ['-h', '--help', 'help'].include? ARGV[0]
 puts "Scans the current directory for files with missing Apache "
 puts "license headers."
 puts "   ruby check_license_headers.rb      # list files"
 puts "   ruby check_license_headers.rb add  # add headers automatically"
else
 
 HeadersCheck.new.check_files(ARGV[1], ARGV[0] != 'add')
end
