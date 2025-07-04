using System;
using System.Collections.Generic;
using UnityEngine;

namespace Game.Utils
{
    /// <summary>
    /// 提供字符串读取和解析功能的配置类
    /// </summary>
    public sealed class StringReadTools
    {
        /// <summary>
        /// 从字符串中读取一个浮点数
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的浮点数</returns>
        public static float ReadFloat(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            if (float.TryParse(ReadUntil(ref line, ch, skipcount), out float ret))
            {
                return ret;
            }
            else
            {
                Debug.LogError($"ReadFloat failed: {line.ToString()}");
            }

            return 0f;
        }

        /// <summary>
        /// 从字符串中读取一个整数
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的整数</returns>
        public static int ReadInt(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            if (int.TryParse(ReadUntil(ref line, ch, skipcount), out int ret))
            {
                return ret;
            }
            else
            {
                Debug.LogError($"ReadInt failed: {line.ToString()}");
            }

            return 0;
        }

        /// <summary>
        /// 从字符串中读取一个无符号整数
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的无符号整数</returns>
        public static uint ReadUInt(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            if (uint.TryParse(ReadUntil(ref line, ch, skipcount), out uint ret))
            {
                return ret;
            }
            else
            {
                Debug.LogError($"ReadUInt failed: {line.ToString()}");
            }

            return 0;
        }

        /// <summary>
        /// 从字符串中读取一个字符串
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的字符串</returns>
        public static string ReadStr(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            return ReadUntil(ref line, ch, skipcount).ToString();
        }

        /// <summary>
        /// 从字符串中读取一个布尔值
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的布尔值</returns>
        public static bool ReadBool(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            if (bool.TryParse(ReadUntil(ref line, ch, skipcount), out bool ret))
            {
                return ret;
            }
            else
            {
                Debug.LogError($"ReadBool failed: {line.ToString()}");
            }

            return false;
        }

        /// <summary>
        /// 从字符串中读取直到指定字符的子字符串
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="skipcount">跳过的字符数</param>
        /// <returns>解析出的子字符串</returns>
        public static ReadOnlySpan<char> ReadUntil(ref ReadOnlySpan<char> line, string ch, int skipcount = 1)
        {
            int idx = line.IndexOf(ch);
            ReadOnlySpan<char> ret;

            if (idx == -1)
            {
                ret = line.Slice(0, line.Length);
                line = line.Slice(0, 0);
            }
            else
            {
                ret = line.Slice(0, idx);
                line = line.Slice(idx + skipcount);
            }

            return ret;
        }

        public static List<float> ReadFloatArray(string line, string ch, int Expectedlength = 0)
        {
            ReadOnlySpan<char> span = line;
            return ReadFloatArray(ref span, ch, Expectedlength);
        }

        /// <summary>
        /// 从字符串中读取一个浮点数数组
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="Expectedlength">期望的数组长度</param>
        /// <returns>解析出的浮点数数组</returns>
        public static List<float> ReadFloatArray(ref ReadOnlySpan<char> line, string ch, int Expectedlength = 0)
        {
            var floatList = new List<float>();
            while (!line.IsEmpty)
            {
                var floatValue = ReadFloat(ref line, ch);
                floatList.Add(floatValue);

                if (line.IndexOf(ch) == -1 && line.Length > 0)
                {
                    floatList.Add(ReadFloat(ref line, ch));
                    break;
                }
            }

            if (Expectedlength != 0 && floatList.Count != Expectedlength)
            {
                Debug.LogError($"ReadFloatArray length mismatch: expected {Expectedlength}, got {floatList.Count}");
            }

            return floatList;
        }

        public static List<int> ReadIntArray(string line, string ch, int Expectedlength = 0)
        {
            ReadOnlySpan<char> span = line;
            return ReadIntArray(ref span, ch, Expectedlength);
        }

        /// <summary>
        /// 从字符串中读取一个整数数组
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="ch">分隔符</param>
        /// <param name="Expectedlength">期望的数组长度</param>
        /// <returns>解析出的整数数组</returns>
        public static List<int> ReadIntArray(ref ReadOnlySpan<char> line, string ch, int Expectedlength = 0)
        {
            var intList = new List<int>();
            while (!line.IsEmpty)
            {
                var intValue = ReadInt(ref line, ch);
                intList.Add(intValue);

                if (line.IndexOf(ch) == -1 && line.Length > 0)
                {
                    intList.Add(ReadInt(ref line, ch));
                    break;
                }
            }

            if (Expectedlength != 0 && intList.Count != Expectedlength)
            {
                Debug.LogError($"ReadIntArray length mismatch: expected {Expectedlength}, got {intList.Count}");
            }

            return intList;
        }

        public static List<string> ReadStringArray(string line, string c, int Expectedlength = 0)
        {
            ReadOnlySpan<char> span = line;
            return ReadStringArray(ref span, c, Expectedlength);
        }

        /// <summary>
        /// 从字符串中读取一个字符串数组
        /// </summary>
        /// <param name="line">输入的字符串</param>
        /// <param name="c">分隔符</param>
        /// <param name="Expectedlength">期望的数组长度</param>
        /// <returns>解析出的字符串数组</returns>
        public static List<string> ReadStringArray(ref ReadOnlySpan<char> line, string c, int Expectedlength = 0)
        {
            var stringList = new List<string>();
            while (!line.IsEmpty)
            {
                var str = ReadUntil(ref line, c);
                stringList.Add(str.ToString());

                if (line.IndexOf(c) == -1 && line.Length > 0)
                {
                    stringList.Add(ReadUntil(ref line, c).ToString());
                    break;
                }
            }

            if (Expectedlength != 0 && stringList.Count != Expectedlength)
            {
                Debug.LogError($"ReadStringArray length mismatch: expected {Expectedlength}, got {stringList.Count}");
            }

            return stringList;
        }
    }
}