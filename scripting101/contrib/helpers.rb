def log(s)
    puts s
end

# returns the name of the calling function
def getFunctionName()
    return /in `([^']*)'/.match(caller[0].to_s)[1]
end

def displayMessages( m)
    log m.join("\n")
end
