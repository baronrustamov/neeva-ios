def get_current_branch_name
  return `git rev-parse --abbrev-ref HEAD`.strip
end

def is_on_main_branch
  return get_current_branch_name == "main"
end

# increment (major|minor|patch) version number by 1 specified by the token index of the version
#
# version: version string with . delimiter (e.g., x.xx.x)
# version_idx: which version index to bump the number
def increment_version(version, version_idx)
  version_arr = version.split('.')
  version_arr[version_idx] = (version_arr[version_idx].to_i + 1).to_s
  return version_arr.join(".")
end

def get_marketing_version
  version_str = File.open("Client/AppConfig.xcconfig").grep(/BROWSER_MARKETING_VERSION = /)
  marketing_version = (version_str[0].to_s.split)[2]
  return marketing_version
end

def get_build_number
  build_number_str = File.open("Client/AppConfig.xcconfig").grep(/BROWSER_PROJECT_VERSION = /)
  build_number = (build_number_str[0].to_s.split)[2]
  return build_number
end

def increment_marketing_version(which_version)
  if (which_version == "minor")
    version = increment_version(get_marketing_version, 1)
    version_arr = version.split('.')
    version_arr[2] = "0"
    return version_arr.join(".")
  else
    return increment_version(get_marketing_version, 2)
  end
end

def increment_build_number
  if (get_current_branch_name == "main")
    return (get_build_number.to_i + 1).to_s
  else
    return increment_version(get_build_number, 1)
  end
end

# execute a shell command and print the output
def execute_shell_command(cmd)
  output = `#{cmd}`
  puts output
  if ($?.exitstatus != 0)
    exit $?.exitstatus
  end
end

def create_build_tag
   tag_name = "fastlane/Build-#{get_build_number}"
  puts "creating tag for #{tag_name}"
  commit_hash = `git log -1 --oneline | cut -d' ' -f1`
  execute_shell_command("git tag -a #{tag_name} -m 'v#{get_marketing_version}' #{commit_hash}")
  execute_shell_command("git push origin \"#{tag_name}\" --no-verify")
end 

def bump_version(which_version)
  puts "bumping version..." 
  `sed -i -e 's/#{get_marketing_version}/#{increment_marketing_version(which_version)}/g' Client/AppConfig.xcconfig`
  `sed -i -e 's/#{get_build_number}/#{increment_build_number}/g' Client/AppConfig.xcconfig`
  `rm Client/AppConfig.xcconfig-e`
  execute_shell_command("/usr/libexec/PlistBuddy -c \"Set :PreferenceSpecifiers:0:DefaultValue #{get_marketing_version}\" Client/Application/Settings.bundle/Root.plist")
  puts "bumped version to v#{get_marketing_version} (#{get_build_number})"
  execute_shell_command("git diff")
end

def commit_and_push_version_bump(on_main)
  puts "committing..."
  if (on_main)
    execute_shell_command("git checkout -b prepare-for-build-#{get_build_number}")
  end
  execute_shell_command("git commit -a -m \"Preparing for build #{get_build_number}\"")
  execute_shell_command("git push origin #{get_current_branch_name}")
end

def create_pr
  if (get_current_branch_name.start_with?('prepare-'))
    execute_shell_command("gh pr create -t \"Prepare for build #{get_build_number}\" -r \"ios\" -b \"Bumping up version for next build\"")
  end
end

def reviewer(account)
  execute_shell_command("git checkout -b chung/test-#{Time.now().min*Time.now().hour}")
  execute_shell_command("touch i")
  execute_shell_command("git add i")
  execute_shell_command("git commit -a -m \"test\"")
  execute_shell_command("git push origin chung/test-#{Time.now().min*Time.now().hour}")
  puts "creating PR with reviewer: #{account}"
  if (account == '')
    execute_shell_command("gh pr create -t \"Test\" -b \"Test\"")
  else
    execute_shell_command("gh pr create -t \"Test\" -r \"#{account}\" -b \"Test\"")
  end
end

def send_branch_cut_slack_message(branch_build_number, slack_url)
  branch_cut_name = "Build-#{branch_build_number}-release-branch"
  title=":fruitcompany: Release branch *#{branch_cut_name}* created"
  message="<https://github.com/neevaco/neeva-ios/tree/#{branch_cut_name}|Github branch>"
  execute_shell_command("curl -s -X POST -H 'Content-type: application/json' --data \"{ \\\"attachments\\\": [ { \\\"color\\\": \\\"#2eb886\\\", \\\"blocks\\\": [ { \\\"type\\\": \\\"section\\\", \\\"text\\\": { \\\"type\\\": \\\"mrkdwn\\\", \\\"text\\\": \\\"#{title}\\\" } }, { \\\"type\\\": \\\"section\\\", \\\"text\\\": { \\\"type\\\": \\\"mrkdwn\\\", \\\"text\\\": \\\"#{message}\\\" } } ] } ] }\" #{slack_url} > /dev/null")
end 

#
# daily build and deploy action
# This creates build tag, bump up the version and create PR if necessary
# Use this on main/Build-<build_number>-branch-name
#
def daily_build
  on_main = is_on_main_branch

  # Tag creation
  create_build_tag

  # Version bump
  bump_version("patch")

  # commit version
  commit_and_push_version_bump(on_main)

  # create pr
  create_pr
end 

#
# branch cut and build deploy action (weekly)
# This create build tag, cuts the branch, bump up the version on both branches and create any PR if necessary
# Use this on main only
#
def branch_cut_and_build(slack_url)
  if (!is_on_main_branch)
    puts "Branch cut should happen on main. You are running this workflow on #{get_current_branch_name}. Aborting..."
    exit 1
  end
  
  # Tag creation
  create_build_tag

  # Branch cut
  branch_cut_build_number = get_build_number
  branch_cut_name = "Build-#{branch_cut_build_number}-release-branch"
  puts "Branch cut: Creating branch #{branch_cut_name}"
  execute_shell_command("git checkout -b #{branch_cut_name}")
  bump_version("patch")
  commit_and_push_version_bump(false)

  # send slack
  send_branch_cut_slack_message(branch_cut_build_number, slack_url)

  # Switch back to main and bump minor version
  execute_shell_command("git checkout main")
  bump_version("minor")

  # commit version
  commit_and_push_version_bump(true)

  # create pr
  create_pr
end 

