require 'jekyll'

task :default do
  exit(1) unless confirm "Deploy from #{current_branch} branch?"

  if `git status --porcelain`.each_line.count > 0
    error "You have local changes. Commit or stash them before deploying."
  end

  info "Generating site"

  conf = Jekyll.configuration({
    "source"      => ".",
    "destination" => "_site",
    "quiet"       => true,
  })
  Jekyll::Site.new(conf).process

  info "Preparing gh-pages branch"

  `git checkout -q gh-pages`
  `git rm --ignore-unmatch -r -q *`
  `cp -Rf _site/* .`
  `git add -A .`

  changes = `git status --porcelain`

  if changes.length == 0
    puts yellow "No changes to deploy."
    `git checkout -q master`
    exit(0)
  end

  info "Changes to deploy:"

  changes.each_line.map(&:strip).each do |change|
    if change[0] == 'D'
      puts red   "   > #{change.chomp}"
    else
      puts green "   > #{change.chomp}"
    end
  end

  if confirm("Deploy changes?")
    `git commit -qm "#{ask('Release description', 'Site update')}"`
    info "Deploying changes to Github"
    `git push -q origin gh-pages`
    if $?.exitstatus > 0
      error "Failed to deploy site to Github pages."
    end
    puts green "Latest changes deployed successfully to Github pages!"
  else
    info "Cancelling deploy"
    `git reset --hard HEAD`
    `git status --porcelain`.each_line { |l| `rm #{l.sub(/^\?\? /, '')}` }
  end

  `git checkout -q master`
end

def current_branch
  `git rev-parse --abbrev-ref HEAD`.chomp
end

def confirm(msg)
  print "#{msg} [y/n] : "
  STDOUT.flush
  STDIN.gets.chomp == 'y'
end

def ask(msg, default)
  print "#{msg} [#{default}] : "
  STDOUT.flush
  input = STDIN.gets.chomp.strip.squeeze
  input.empty? ? default : input
end

def info(msg)
  puts blue "=> #{msg}"
end

def error(msg)
  puts red msg
  exit(1)
end

{
  :black => 30,
  :red => 31,
  :green => 32,
  :yellow => 33,
  :blue => 34,
  :magenta => 35,
  :cyan => 36,
  :white => 37
}.each do |key, color_code|
  define_method key do |text|
    "\033[#{color_code}m#{text}\033[0m"
  end
end
