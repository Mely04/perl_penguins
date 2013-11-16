use Digest::MD5 qw(md5_hex);
package crypto;

# Static class - no new method
sub getLoginHash {
    my $isLogin  = shift;
    my $password = shift;
    my $rndK     = shift;
    
    return encryptPassword(Digest::MD5::md5_hex(uc(encryptPassword($password)).$rndK.'a1ebe00441f5aecb185d0ec178ca2305Y(02.>\'H}t":E1_root')) if($isLogin);
    return encryptPassword(Digest::MD5::md5_hex($password.$rndK)).$password;
}
sub encryptPassword {
    my $pass = shift;
    return substr($pass, 16, 16).substr($pass, 0, 16);
}
sub generateRndK {
    my @chrs       = ('A'..'Z', 'a'..'z', 0..9, '_', '{', '}');
    my $chrsLength = @chrs;
    my $length     = 20 || shift;
    my $key        = '';
    
    for(my $i = 0; $i != $length; $i++){
        $key .= $chrs[rand($chrsLength)];
    }
    
    return $key;
}
sub generateLoginKey {
    my $client = shift;
    return crypto::generateRndK();
}
1;
