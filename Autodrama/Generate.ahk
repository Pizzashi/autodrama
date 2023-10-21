class Generate
{
    randomString(length)
    {
        ; This is just a scrambled "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local motherList := "WVed175kuEmcMX4R9SZ3jID8xilHYFLwrqGAgOfKCPoyzsQUa2b0TJhtp6NvnB"
            , output := ""
        
        Loop % length {
            Random, rand, 1, % StrLen(motherList)
            output .= SubStr(motherList, rand, 1)
        }

        return output
    }
}