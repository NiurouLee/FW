namespace Game
{
    public class UIParam
    {
        public readonly string UniqueKey;
        public readonly System.Type ControllerType;
        //public readonly string PrefabAssetKey;


        public UIParam(string uniqueKey, System.Type controllerType/*, string prefabAssetKey*/)
        {
            UniqueKey = uniqueKey;
            ControllerType = controllerType;
            //PrefabAssetKey = prefabAssetKey;
        }

        public UIParam(System.Type type/*, string prefabAssetKey*/)
        {
            UniqueKey = type.FullName;
            ControllerType = type;
            //PrefabAssetKey = prefabAssetKey;
        }
    }
}
