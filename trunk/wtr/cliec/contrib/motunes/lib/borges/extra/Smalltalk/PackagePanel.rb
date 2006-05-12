class PackagePanel < Component

  def render_content_on(r)
    r.form do
      r.table do
        PackageManager.allManagers.each do |ea|
          r.tableRowWithLabel_column(ea.packageName, proc do
            self.renderDirectoryEditorForPackage_on(ea, r)
          end)
        end
      end
    end

    r.anchorWithAction_text(proc do
      Smalltalk.snapshot_andQuit(true, false)
    end, 'Save Image')
  end

  def renderDirectoryEditorForPackage_on(aManager, r)
    r.attributeAt_put('size', 50)
    r.textInputWithValue_callback(aManager.directory.fullName,
      proc do |path|
        aManager.directory(FileDirectory.on(path))
      end)
    r.space
    r.submitButtonOn_of(:fileIn, aManager)
  end

end

