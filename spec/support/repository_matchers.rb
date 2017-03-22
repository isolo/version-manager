RSpec::Matchers.define :have_version do |version|
  match do |repo|
    repo.current_local_branch_version == version.to_s
  end
end

RSpec::Matchers.define :have_tag do |version|
  match do |repo|
    repo.current_local_tag == version.to_s
  end
end

RSpec::Matchers.define :have_branch do |version|
  match do |repo|
    repo.current_local_branch == version.to_s
  end
end
