using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnightColorChanger : MonoBehaviour
{
    [SerializeField]
    Color r, g, b, o;

    [SerializeField]
    Renderer knightRenderer;

    public void ChangeColor(string sColor)
    {
        Color color = Color.white;

        switch(sColor)
        {
            case "r":
                color = r;
                break;
            case "g":
                color = g;
                break;
            case "b":
                color = b;
                break;
            case "o":
                color = o;
                break;
        }

        knightRenderer.material.SetColor("_ReplaceColor", color);
    }
}
