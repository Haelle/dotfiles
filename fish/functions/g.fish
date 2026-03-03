function g --description 'Git shortcut: g = status, g <cmd> = git <cmd>' --wraps git
    if test (count $argv) -eq 0
        git status
    else
        git $argv
    end
end
