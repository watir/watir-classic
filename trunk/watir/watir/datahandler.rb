require 'win32ole'

class String

	def pred
		self[0..-2] << (self[-1]-1).chr
	end

end

class DataHandler

	# This allows you to put data in a csv file or an xls file and access it in your scripts for
	# a data driven approach.
	# 
	# You can supply a file with extension csv or xls and it will just work
	#
	# e.g.
	# require 'datahandler'
	# d = DataHandler.new("data.csv")
	# loginId = d.data[0].LoginId		--> line 1 of the csv file and column LoginId
	# pin = d.data[0].Pin				--> line 1 of the cvs file and column Pin
	#
	# b = Datahandler.new("data.xls")
	# loginId = b.data[0].LoginId                   --> line 1 of workbook 1 of the xls file with column LoginId
	#
	# Remember that line 1 of the data is referenced by using 0 - and this excludes the header line.
	#
	def initialize(datafile)
		
		# if the data files are in the same dir as the one you execute from this works
		directory = `dir`
		directory.match(/Directory of(.+)$/)
		working_directory = $1.to_s.gsub(/\\/,"/").gsub(/^\s/,"")
		file = "#{working_directory.chomp}\\#{datafile}"
		
		# otherwise it will take the location you specify
		if File.exists?(file)
			@datafile = file
		else
			@datafile = datafile
		end
		
		@excel = WIN32OLE::new('excel.Application')
		@workbook = @excel.Workbooks.Open(@datafile)
		@worksheet = @workbook.Worksheets(1)
		@excel['Visible'] = false
		
	end
	
	def csv_data
		csv_data = File.readlines(@datafile)
		header = csv_data[0].split(",")
		header.each{|z| z.chomp!}
		data = Struct.new("Data", *header)
		csv_data.shift
		data_array = []
		csv_data.each do |line|
			line.each{|z| line.chomp!}
			data_array << data.new(*line.split(","))
		end
	return data_array
	end
	
	def number_columns
		column = last_column = "a"
		while @worksheet.Range("a1:#{column}1")['Value']
			if !@worksheet.Range("#{column}1")['Value']
				last_column = column.pred
				break
			end
			column.succ!
		end
	last_column
	end
		
	def xls_data
		line = "1"
		data = []
			while @worksheet.Range("a#{line}")['Value']
			   data << @worksheet.Range("a#{line}:#{number_columns}#{line}")['Value']
			   line.succ!
			end
		
		header = data[0].flatten
		dataObject = Struct.new("DataObject", *header)
		data.shift
		data_array = []
		data.each do |line|
			data_array << dataObject.new(*line.flatten)
		end
	@excel.Quit
	@excel = nil
	GC.start
	data_array
	end
	
	def data
		extension = @datafile.split(".")[-1]
		if extension == "xls"
			xls_data
		elsif extension == "csv"
			csv_data
		end
	end
	
end
