require 'spec_helper'

RSpec.shared_examples 'add' do
  let(:build_branch) { "#{build_type}/#{version}" }
  let(:merge_commits) do
    branches.map do |branch|
      "Merge branch '#{branch}' into #{build_branch}"
    end
  end
  let(:command) { ind_flow "#{build_type} add -v #{version} -b #{branches.join(' ')}" }

  before do
    generator = IndFlow::Sandbox::Generate.new
    generator.run
    Dir.chdir generator.local_repository_directory
    ind_flow "#{build_type} start -v #{version}"
  end

  it 'adds a branch to the build branch and pushes it to origin' do
    expect(command[:stderr]).not_to include('There was a problem running')
    expect(command[:exit_status]).to eq(1)

    expect(`git branch`).to include(build_branch)
    merge_commits.each do |merge_commit|
      expect(`git log`).to include(merge_commit)
    end
    expect(`git log origin/#{base_branch}..#{base_branch}`).to be_empty
  end

  it 'cleans up and removes stale branches from local' do
    expect(command[:exit_status]).to eq(0)

    branches.each do |branch|
      expect(`git branch`).not_to include(branch)
    end
  end

  context 'when branch does not exist' do
    let(:branches) { [ "#{build_type}/404-not-found" ] }

    it 'should not add to the build branch' do
      expect(command[:stderr]).to include('There was a problem running')
      expect(command[:exit_status]).to eq(1)
    end
  end

  shared_examples 'should not continue' do
    it 'should not continue' do
      expect(command[:exit_status]).to eq(1)
      merge_commits.each do |merge_commit|
        expect(`git log`).not_to include(merge_commit)
      end
    end
  end

  context 'when version is not specified' do
    let(:command) { ind_flow "#{build_type} add -b #{branches.join(' ')}" }

    it_behaves_like 'should not continue'

    it 'should return a helpful error' do
      expect(command[:stderr]).to include('No value provided for required options \'--version\'')
    end
  end

  context 'when branch(es) is(are) not specified' do
    let(:command) { ind_flow "#{build_type} add -v #{version}" }

    it_behaves_like 'should not continue'

    it 'should return a helpful error' do
      expect(command[:stderr]).to include('No value provided for required options')
    end
  end
end

RSpec.shared_examples 'add with merge conflict' do
  let(:build_branch) { "#{build_type}/#{version}" }
  let(:merge_commits) do
    branches.map do |branch|
      "Merge branch '#{branch}' into #{build_branch}"
    end
  end
  let(:command) { ind_flow "#{build_type} add -v #{version} -b #{branches.join(' ')}" }

  before do
    generator = IndFlow::Sandbox::Generate.new
    generator.run
    Dir.chdir generator.local_repository_directory
    ind_flow "#{build_type} start -v #{version}"
  end

  it 'should merge the branches with no conflicts' do
    expect(command[:stderr]).to include(error_message)
    expect(command[:exit_status]).to eq(1)

    expected_success_branches.each do |branch|
      expect(`git log`).to include("Merge branch '#{branch}' into #{build_branch}")
    end
  end
end