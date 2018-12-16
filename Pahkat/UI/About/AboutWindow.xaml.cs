using System.Reflection;
using System.Windows;
using Pahkat.Models;

namespace Pahkat.UI.About
{
    public partial class AboutWindow : Window
    {
        public AboutWindow()
        {
            InitializeComponent();

            LblAppName.Text = Strings.AppName;
            LblVersion.Text = AssemblyVersion.From(Assembly.GetEntryAssembly().GetName().Version)
                .ToSemanticVersion()
                .ToString();
            BtnWebsite.Content = "Divvun Website";
            BtnWebsite.Click += (sender, e) =>
            {
                System.Diagnostics.Process.Start("http://divvun.no");
            };
        }
    }
}
