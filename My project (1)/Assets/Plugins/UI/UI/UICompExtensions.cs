public static class UICompExtensions
{

    // TMPro.TextMeshProUGUI
    public static void ExSetText(this TMPro.TextMeshProUGUI comp, string text)
    {
        if (comp != null)
            comp.text = text;

#if UNITY_EDITOR
        if (comp != null)
        {
            const string TypeName = "client.LanText";

            if (m_LanTextType == null)
            {
                var list = System.AppDomain.CurrentDomain.GetAssemblies();

                foreach (var assembly in list)
                {
                    if (assembly.GetName().Name == "AGame.Logic.Runtime")
                    {
                        m_LanTextType = assembly.GetType(TypeName);
                        if (m_LanTextType == null)
                        {
                            Game.DevDebuger.LogError("UICompExtensions", $"can not find the type: {TypeName}");
                        }
                        break;
                    }
                }

            }

            if (m_LanTextType != null)
            {
                var lancomp = comp.gameObject.GetComponent(m_LanTextType);
                if (lancomp != null)
                {
                    string path = Ez.Core.TransformUtil.GetTransformPath(comp.transform);
                    Game.DevDebuger.LogError("UICompExtensions", $"remove {TypeName} at: {path}");
                }
            }
        }
#endif
    }

#if UNITY_EDITOR
    private static System.Type m_LanTextType;
#endif
}