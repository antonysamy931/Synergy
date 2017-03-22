using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public static class PasswordEncription
    {
        private static string SecurityCode = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$";

        public static string CreateSHAHash(string passwordSHA512)
        {
            SHA512Managed sha512 = new SHA512Managed();
            Byte[] EncryptedSHA512 = sha512.ComputeHash(Encoding.UTF8.GetBytes(string.Concat(passwordSHA512, SecurityCode)));
            sha512.Clear();
            return Convert.ToBase64String(EncryptedSHA512);
        }
    }
}
