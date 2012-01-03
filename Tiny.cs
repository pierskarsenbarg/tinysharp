﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;

namespace TinyProj
{
    public static class Tiny
    {
        private const string _key = "** insert key here **";
        public static string ToTiny(int ID)
        {
            List<string> HexN = new List<string>();
            int radix = _key.Length;
            char[] set = _key.ToCharArray();
            while(true)
            {
                int R = ID % radix;
                if (HexN.Count == 0)
                {
                    HexN.Add(set[R].ToString());
                }
                else
                {
                    HexN.Insert(0,set[R].ToString());
                }
                ID = (ID-R)/radix;
                if(ID==0)
                    break;
            
            }
            return string.Join("", HexN.ToArray());
        }

        public static int ReverseTiny(string hash)
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

        public static string GenerateSet()
        {
            List<string> TinyList = new List<string>();
            for (int i = 65;i<=122;i++)
            {
                if (i < 91 || i > 96)
                    TinyList.Add(Convert.ToChar(i).ToString());
            }
            for (int i = 0; i <= 9; i++)
            {
                TinyList.Add(i.ToString());
            }

            string[] TinyArray = TinyList.ToArray();
            RNGCryptoServiceProvider rnd = new RNGCryptoServiceProvider();
            return String.Join("", TinyArray.OrderBy(x => GetNextInt32(rnd)).ToArray());
        }

        private static int GetNextInt32(RNGCryptoServiceProvider rnd)
        {
            byte[] randomInt = new byte[4];
            rnd.GetBytes(randomInt);
            return Convert.ToInt32(randomInt[0]);
        }

    }
}