using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Security.Cryptography;

namespace TinySharp
{
    /// <summary>
    /// A reversable base62 ID obfuscater
    /// </summary>
    public class Tiny
    {
        private readonly string _key;

        public Tiny()
        {
            _key = ConfigurationManager.AppSettings["TinySharpKey"];
        }

        public Tiny(string key)
        {
            _key = key;
        }

        /// <summary>
        /// Convert ID into reversable hash
        /// </summary>
        /// <param name="id">ID to be converted</param>
        /// <returns>Hash of ID</returns>
        public string ToHash(int id)
        {
            var hexN = new List<char>();
            int radix = _key.Length;
            char[] characterSet = _key.ToCharArray();
            while(true)
            {
                int r = id % radix;
                if (hexN.Count == 0)
                {
                    hexN.Add(characterSet[r]);
                }
                else
                {
                    hexN.Insert(0, characterSet[r]);
                }
                id = (id-r)/radix;
                if (id == 0)
                {
                    break;
                }

            }
            return string.Join("", hexN.ToArray());
        }

        /// <summary>
        /// Converts hash to ID
        /// </summary>
        /// <param name="hash">Hash to be converted</param>
        /// <returns>ID</returns>
        public int ReverseHash(string hash)
        {
            int radix = _key.Length;
            int hashlen = hash.Length;
            char[] hashchararray = hash.ToCharArray();
            int N = 0;
            for (int i = 0;i<hashlen;i++)
            {
                N += _key.IndexOf(hashchararray[i]) * (int)Math.Pow(radix,(hashlen-i-1));
            }
            return N;
        }

        /// <summary>
        /// Method for generating a key
        /// </summary>
        /// <returns></returns>
        public static string GenerateKey()
        {
            var tinyList = new List<string>();
            for (int i = 65; i <= 122; i++)
            {
                if (i < 91 || i > 96)
                {
                    tinyList.Add(Convert.ToChar(i).ToString());
                }
            }
            for (int i = 0; i <= 9; i++)
            {
                tinyList.Add(i.ToString());
            }

            var rnd = new RNGCryptoServiceProvider();
            return string.Join("", tinyList.OrderBy(x => GetNextInt32(rnd)));
        }

        private static int GetNextInt32(RNGCryptoServiceProvider rnd)
        {
            byte[] randomInt = new byte[4];
            rnd.GetBytes(randomInt);
            return Convert.ToInt32(randomInt[0]);
        }

    }
}