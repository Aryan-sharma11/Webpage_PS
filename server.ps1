Start-PodeServer -Thread 2 {
    # the rest of the logic goes here!
    Add-PodeEndpoint -Address * -Port 8080 -Protocol Http -Name 'app'
    Add-PodeEndpoint -Address * -Port 8001 -Protocol Http 
    Set-PodeViewEngine -Type Pode
    
    # tell this server to run as a desktop gui
    Show-PodeGui -Title 'Pode Desktop Application' -Icon '.\mosiac2.png' -EndpointName 'app' -ResizeMode 'NoResize'
    
    
      # setting up session middleware and duration will be extended with each request 
    Enable-PodeSessionMiddleware -Duration 120 -Extend

    New-PodeAuthScheme -Form | Add-PodeAuth -Name 'Login' -FailureUrl '/login' -SuccessUrl '/' -ScriptBlock {
        param($username, $password)
    
        # here you'd check a real user storage, this is just for example
        if ($username -eq 'Aryan' -and $password -eq '007') {
            return @{
                User = @{
                    ID ='1'
                    Name = 'Aryan'
                    Type = 'Human'
                }
            }
        }
        
        # aww geez! no user was found
        return @{ Message = 'Invalid details supplied' }
    }
    Add-PodeRoute -Method Get -Path '/' -Authentication 'Login' -ScriptBlock {
        $WebEvent.Session.Data.Views++
    
        Write-PodeViewResponse -Path 'auth-home' -Data @{
            Username = $WebEvent.Auth.User.Name;
            Views = $WebEvent.Session.Data.Views;
        }
    }
    # the login page itself
    Add-PodeRoute -Method Get -Path '/login' -Authentication 'Login' -Login -ScriptBlock {
        Write-PodeViewResponse -Path 'auth-login' -FlashMessages
    }

    # the POST action for the <form>
    Add-PodeRoute -Method Post -Path '/login' -Authentication 'Login' -Login

    Add-PodeRoute -Method Post -Path '/logout' -Authentication 'Login' -Logout


}