# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/environment'

require 'fileutils'

class Page
  attr_reader :name
  ATTACHMENTS_DIR = '_attachments'
  LOGICAL_PATH_SEPARATOR = '／'

  def initialize(name, rev = nil)
    @name = File.basename(name)
    @rev = rev
  end

  def self.logical_path_separator
    LOGICAL_PATH_SEPARATOR
  end

  def filename
    @filename ||= File.join(GIT_REPO, @name)
  end

  def attach_dir
    @attach_dir ||= File.join(GIT_REPO, ATTACHMENTS_DIR, @name.downcase)
  end

  def body
    @body ||= render(raw_body)
  end

  def branch_name
    $repo.current_branch
  end

  def updated_at
    commit ? commit.committer_date : ''
  end

  def breadcrumbs
    parent = nil
    @breadcrumbs ||= @name.split(LOGICAL_PATH_SEPARATOR).map{ |e|
      if parent
        parent += LOGICAL_PATH_SEPARATOR + e
      else
        parent = e
      end
      [e, parent]
    }
  end

  def raw_body
    if @rev
      @raw_body ||= blob.contents
    else
      @raw_body ||= File.exists?(filename) ? File.read(filename) : ''
    end
  end

  def rev_or_master
    @rev || 'master'
  end

  def update(content, message = nil)
    File.open(filename, 'w') { |f| f << content }
    commit_message = tracked? ? "edited #{@name}" : "created #{@name}"
    commit_message += ' : ' + message if message && message.length > 0
    begin
      $repo.add(@name)
      $repo.commit(commit_message)
    rescue
      # FIXME I don't like this, why is there a catchall here?
      nil
    end
    @body = nil; @raw_body = nil
    @body
  end

  def tracked?
    $repo.ls_files.keys.include?(@name)
  end

  def children
    @children ||= $repo.ls_files(@name + LOGICAL_PATH_SEPARATOR + '*').keys
  end

  def history
    return nil unless tracked?
    @history ||= $repo.log.path(@name)
  end

  def delta(rev)
    $repo.diff(rev, rev_or_master).path(@name).patch
  end

  def commit
    @commit ||= $repo.log.object(rev_or_master).path(@name).first
  end

  def previous_commit
    @previous_commit ||= $repo.log(2).object(rev_or_master).path(@name).to_a[1]
  end

  def next_commit
    if (self.history.first.sha == self.commit.sha)
      @next_commit ||= nil
    else
      matching_index = nil
      history.each_with_index { |c, i| matching_index = i if c.sha == self.commit.sha }
      @next_commit ||= history.to_a[matching_index - 1]
    end
  rescue
#    FIXME weird catch-all error handling
    @next_commit ||= nil
  end

  def version(rev)
    render(blob.contents)
  end

  def blob
    @blob ||= ($repo.gblob(rev_or_master + ':' + @name))
  end

  # save a file into the _attachments directory
  def save_file(file, name = '')
    if name.size > 0
      filename = name + File.extname(file[:filename])
    else
      filename = file[:filename]
    end
    FileUtils.mkdir_p(attach_dir) if !File.exists?(attach_dir)
    new_file = File.join(attach_dir, filename)

    f = File.new(new_file, 'w')
    f.write(file[:tempfile].read)
    f.close

    commit_message = "uploaded #{filename} for #{@name}"
    begin
      $repo.add(new_file)
      $repo.commit(commit_message)
    rescue
      # FIXME why!??
      nil
    end
  end

  def delete_file(file)
    file_path = File.join(attach_dir, file)
    if File.exists?(file_path)
      File.unlink(file_path)

      commit_message = "removed #{file} for #{@name}"
      begin
        $repo.remove(file_path)
        $repo.commit(commit_message)
      rescue
        # FIXME why is this here!?
        nil
      end

    end
  end

  def attachments
    if File.exists?(attach_dir)
      return Dir.glob(File.join(attach_dir, '*')).map { |f| Attachment.new(f, @name) }
    else
      false
    end
  end


  class Attachment
    attr_accessor :path, :page_name

    def initialize(file_path, name)
      @path = file_path
      @page_name = name
    end

    def name
      File.basename(@path)
    end

    # TODO: check if the singular "_attachment "is correct
    def link_path
      File.join('/_attachment', @page_name, name)
    end

    def delete_path
      File.join('/a/file/delete', @page_name, name)
    end

    def image?
      ext = File.extname(@path)
      case ext
      when '.png', '.jpg', '.jpeg', '.gif'; return true
      else; return false
      end
    end

    def size
      size = File.size(@path).to_i
      case
      when size.to_i == 1;     "1 Byte"
      when size < 1024;        "%d Bytes" % size
      when size < (1024*1024); "%.2f KB"  % (size / 1024.0)
      else                     "%.2f MB"  % (size / (1024 * 1024.0))
      end.sub(/([0-9])\.?0+ /, '\1 ' )
    end
  end

  def render(content)
    Facwparser.to_html(content, {'jira_browse_url' => JIRA_BROWSE_URL})
  end

end

