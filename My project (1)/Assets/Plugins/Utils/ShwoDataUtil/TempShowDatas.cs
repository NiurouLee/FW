using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using client;
using Game.ShwoDataUtil;
using UnityEngine;

namespace Game
{
    public class TempShowDatas
    {
        static Dictionary<string, object> _datas = new Dictionary<string, object>();

        /// <summary>
        /// 需要在数据可视化显示的数据 push进来就行
        /// </summary>
        /// <param name="obj"></param>
        public static void PushData(object obj, string name = "")
        {
            _datas[TypeUtil.GetSimplifiedName(obj.GetType()) + name] = obj;
        }

        public static Dictionary<string, object> GetDatas()
        {
            return _datas;
        }

        public static byte[] CompressString(string text)
        {
            byte[] buffer = Encoding.UTF8.GetBytes(text);
            using (MemoryStream memoryStream = new MemoryStream())
            {
                using (GZipStream gzip = new GZipStream(memoryStream, CompressionMode.Compress, true))
                {
                    gzip.Write(buffer, 0, buffer.Length);
                }

                return memoryStream.ToArray();
            }
        }
        public static byte[] DeumAllData()
        {

            var values = ModelManager.GetAll().ToArray();//  _datas.Values.ToArray();
            List<byte[]> dataList = new List<byte[]>();

            foreach (object keyValue in values)
            {
                try
                {
                    if (keyValue is IModel model && model.IsDataCollect())
                    {
                        string data = model.DataCollect();
                        string fileName = keyValue.GetType().Name + ".txt";
                        byte[] fileData = Encoding.UTF8.GetBytes(data);
                        byte[] fileNameBytes = Encoding.UTF8.GetBytes(fileName);
                        int fileNameLength = fileNameBytes.Length;
                        int fileDataLength = fileData.Length;

                        using (MemoryStream ms = new MemoryStream())
                        {
                            using (BinaryWriter writer = new BinaryWriter(ms))
                            {
                                writer.Write(fileNameLength);
                                writer.Write(fileNameBytes);
                                writer.Write(fileDataLength);
                                writer.Write(fileData);
                            }

                            dataList.Add(ms.ToArray());
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError(keyValue.GetType().Name + " DeumAllData Error " + e.Message);
                }
            }

            byte[] allData = dataList.SelectMany(a => a).ToArray();
            // byte[] compressedData;
            // using (MemoryStream compressedStream = new MemoryStream())
            // {
            //     using (GZipStream gzipStream = new GZipStream(compressedStream, CompressionMode.Compress))
            //     {
            //         gzipStream.Write(allData, 0, allData.Length);
            //     }
            //
            //     compressedData = compressedStream.ToArray();
            // }

            return allData;
            // string outputPath = Path.Combine(Application.persistentDataPath, "AllData.bin");
            // File.WriteAllBytes(outputPath, compressedData);
            //
            // Debug.Log("All data has been compressed into: " + outputPath);
        }
    }
}