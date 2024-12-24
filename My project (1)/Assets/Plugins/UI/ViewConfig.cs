using Unity.VisualScripting.Antlr3.Runtime;


public class ViewConfig
{
    public string Name;
    public string AssetPath;

    /// <summary>
    /// 31位 0 view 1 window
    /// 30位 
    ///
    /// 0-15 ExclusionGroup
    /// </summary>
    public BitField32 Set;
}