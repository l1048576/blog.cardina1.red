module Larry
  module Git

    def git_repo_url
      "https://github.com/lo48576/blog.cardina1.red"
    end

    def git_file_url(path, commit='master')
      "#{git_repo_url}/blob/#{commit}/#{path}"
    end

    def git_tree_url(path='', commit='master')
      "#{git_repo_url}/tree/#{commit}#{"/#{path}" if !path.empty?}"
    end

    def git_history_url(path='', commit='master')
      "#{git_repo_url}/commits/#{commit}#{"/#{path}" if !path.empty?}"
    end

    def git_repo_hash
      blk = -> {
        hash = `git rev-parse --verify HEAD`.strip
        hash if $? == 0
      }
      @git_repo_hash ||= blk.call
    end

    def git_file_commit_hash(path)
      hash = %x(git log -n 1 --pretty='format:%H' -- #{path}).strip
      hash if $? == 0
    end

    def git_available
      blk = -> {
        `git --version`
        $? == 0
      }
      @git_available ||= blk.call
    end
  end
end

include Larry::Git
