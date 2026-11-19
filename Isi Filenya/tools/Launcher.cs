using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

[assembly: AssemblyTitle("Remove Windows AI bay Mekatik")]
[assembly: AssemblyProduct("Remove Windows AI bay Mekatik")]
[assembly: AssemblyCompany("Mekatik")]
[assembly: AssemblyCopyright("(c) 2026 Mekatik")]
[assembly: AssemblyVersion("1.0.4.0")]

static class Launcher
{
    const string Title = "Remove Windows AI bay Mekatik";

    [STAThread]
    static void Main()
    {
        string exeDir = AppDomain.CurrentDomain.BaseDirectory;

        // Struktur zip: file .exe di luar, semua file program ada di dalam folder "Isi Filenya".
        // Folder src di samping .exe tetap dikenali sebagai cadangan (struktur lama).
        string root = Path.Combine(exeDir, "Isi Filenya");
        string script = Path.Combine(Path.Combine(root, "src"), "Main.ps1");
        if (!File.Exists(script))
        {
            root = exeDir;
            script = Path.Combine(Path.Combine(root, "src"), "Main.ps1");
        }
        if (!File.Exists(script))
        {
            MessageBox.Show("File Isi Filenya\\src\\Main.ps1 tidak ditemukan.\n" +
                "Pastikan file .exe ini berada satu folder dengan folder 'Isi Filenya' dan ekstrak seluruh isi zip terlebih dahulu (jangan dijalankan langsung dari dalam zip).",
                Title, MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }
        try
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = "powershell.exe";
            psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + script + "\"";
            psi.WorkingDirectory = root;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;
            Process.Start(psi);
        }
        catch (Exception ex)
        {
            MessageBox.Show("Gagal menjalankan PowerShell:\n\n" + ex.Message,
                Title, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
