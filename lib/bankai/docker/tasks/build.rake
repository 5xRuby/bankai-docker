# frozen_string_literal: true

Bankai::Docker::Builder.install_tasks

desc 'Preview Dockerfile'
task :preview do
  puts Bankai::Docker::File.print
end
