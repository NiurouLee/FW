using Google.Protobuf;
using System;
using System.Collections;
using System.Reflection;
using UnityEngine;

namespace Game.ShwoDataUtil
{
    public class TypeUtil
    {
        //判断是否是数组
        public static bool IsIEnumerable(object value)
        {
            return typeof(IEnumerable).IsAssignableFrom(value.GetType());
        }
        public static bool IsIEnumerable(Type value)
        {
            return typeof(IEnumerable).IsAssignableFrom(value);
        }
        public static bool IsMessage(object value)
        {
            return typeof(IMessage).IsAssignableFrom(value.GetType());
        }
        public static bool IsMessage(Type value)
        {
            return typeof(IMessage).IsAssignableFrom(value);
        }
        public static bool IsStruct(object value)
        {
            return value.GetType().IsTypeDefinition;
        }
        public static bool IsStruct(Type value)
        {
            return value.IsTypeDefinition;
        }
        public static bool IsGenericDict(Type value)//value
        {
            return value.IsGenericType && value.Name == "KeyValuePair`2";
        }
        public static bool IgoneType(Type value)
        {
            if (typeof(Assembly).IsAssignableFrom(value)
                || isSystemType(value)
                || isUIControllerBase(value)
                || typeof(Material).IsAssignableFrom(value)
                || typeof(Texture).IsAssignableFrom(value)
                || typeof(Shader).IsAssignableFrom(value)
                || typeof(ComputeShader).IsAssignableFrom(value)
                || typeof(Component).IsAssignableFrom(value)
                || typeof(Animation).IsAssignableFrom(value)
                || typeof(AnimationClip).IsAssignableFrom(value)
                || typeof(AnimationCurve).IsAssignableFrom(value)
                || typeof(Renderer).IsAssignableFrom(value)
                || typeof(GameObject).IsAssignableFrom(value)
                || typeof(Transform).IsAssignableFrom(value))
            {
                return true;
            }
            return false;
        }
        public static bool isMonoBehaviour(Type value)
        {
            return typeof(MonoBehaviour).IsAssignableFrom(value);
        }
        public static bool isSystemType(Type value)
        {
            return typeof(System.Type).IsAssignableFrom(value);
        }
        public static bool isUIControllerBase(Type value)
        {
            return typeof(Ez.UI.UIControllerBase).IsAssignableFrom(value);

        }
        public static bool isUnityObject(Type value)
        {
            return typeof(UnityEngine.Object).IsAssignableFrom(value);
        }
        public static BindingFlags GetBindingFlags(Type value)
        {
            BindingFlags f = BindingFlags.Public | BindingFlags.Instance | BindingFlags.NonPublic;
            if (IsGenericDict(value) || IsMessage(value) || IsIEnumerable(value) || isUnityObject(value))//System.Reflection.MethodInfo
            {
                return BindingFlags.Public | BindingFlags.Instance;
            }
            return f;
        }
        public static bool IsValueArray(Type calue)
        {
            if (calue.IsSZArray)
            {
                if (calue.GetElementType().IsValueType)
                {
                    return true;
                }
            }
            return false;
        }
        public static bool IsDelegate(Type calue)
        {
            return typeof(Delegate).IsAssignableFrom(calue);
        }

        public static string GetSimplifiedName(Type type)
        {
            if (!type.IsGenericType)
                return type.Name;

            string typeName = type.GetGenericTypeDefinition().Name;
            if (typeName.IndexOf('`')!=-1)
            {
                typeName = typeName.Substring(0, typeName.IndexOf('`'));
            }
            return $"{typeName}"; // 组合简化的泛型类型名称
        }
        //        static JsonFormatter s_MsgFormatter;
        //        public static JsonFormatter MsgFormatter
        //        {
        //            get
        //            {
        //                if (s_MsgFormatter == null)
        //                {
        //                    JsonFormatter.Settings set = JsonFormatter.Settings.Default.WithFormatDefaultValues(true)//设置默认值是否显示
        //.WithIndentation("\t");
        //                    s_MsgFormatter = new JsonFormatter(set);
        //                }
        //                return s_MsgFormatter;
        //            }
        //        }
    }
}
