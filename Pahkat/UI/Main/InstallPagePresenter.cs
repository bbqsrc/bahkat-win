﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Threading;
using System.Windows;
using Newtonsoft.Json;
using Pahkat.Models;
using Pahkat.Service.CoreLib;

namespace Pahkat.UI.Main
{
    public struct InstallSaveState
    {
        public bool IsCancelled;
        public bool RequiresReboot;
    }

    public class InstallPagePresenter
    {
        private readonly IInstallPageView _view;
        private readonly IPahkatTransaction _transaction;
        private readonly IScheduler _scheduler;
        private readonly CancellationTokenSource _cancelSource;
        private readonly string _stateDir;
        
        public InstallPagePresenter(IInstallPageView view,
            IPahkatTransaction transaction,
            IScheduler scheduler)
        {
            _view = view;
            _transaction = transaction;
            _scheduler = scheduler;

            _cancelSource = new CancellationTokenSource();

            var appdata = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            _stateDir = Path.Combine(appdata, "Pahkat", "state");
        }

        public void SaveResultsState(InstallSaveState state)
        {
            Directory.CreateDirectory(_stateDir);
            var jsonPath = Path.Combine(_stateDir, "results.json");
            File.WriteAllText(jsonPath, JsonConvert.SerializeObject(state));
        }

        public InstallSaveState ReadResultsState()
        {
            var jsonPath = Path.Combine(_stateDir, "results.json");
            return JsonConvert.DeserializeObject<InstallSaveState>(File.ReadAllText(jsonPath));
        }

        private IDisposable PrivilegedStart()
        {
            var app = (IPahkatApp) Application.Current;
            _view.SetTotalPackages(_transaction.Actions.Length);

            var keys = new HashSet<AbsolutePackageKey>(_transaction.Actions.Select((x) => x.Id));
            var packages = new Dictionary<AbsolutePackageKey, Package>();
            
            // Cache the packages in advance
            foreach (var repo in app.Client.Repos())
            {
                var copiedKeys = new HashSet<AbsolutePackageKey>(keys);
                foreach (var key in copiedKeys)
                {
                    var package = repo.Package(key);
                    if (package != null)
                    {
                        keys.Remove(key);
                        packages[key] = package;
                    }
                }
            }

            var requiresReboot = false;

            return _transaction.Process()
                .Delay(TimeSpan.FromSeconds(0.5))
                .ObserveOn(_scheduler)
                .Subscribe((evt) =>
            {
                var action = _transaction.Actions.First((x) => x.Id.Equals(evt.PackageKey));
                var package = packages[evt.PackageKey];
                
                switch (evt.Event)
                {
                    case PackageEventType.Installing:
                        _view.SetStarting(action.Action, package);
                        if (package.WindowsInstaller.RequiresReboot)
                        {
                            requiresReboot = true;
                        }
                        break;
                    case PackageEventType.Uninstalling:
                        _view.SetStarting(action.Action, package);
                        if (package.WindowsInstaller.RequiresUninstallReboot)
                        {
                            requiresReboot = true;
                        }
                        break;
                    case PackageEventType.Completed:
                        _view.SetEnding();
                        break;
                }
            },
            _view.HandleError,
            () => {
                if (_cancelSource.IsCancellationRequested)
                {
                    this._view.ProcessCancelled();
                }
                else
                {
                    _view.ShowCompletion(false, requiresReboot);
                }
            });
        }

        public IDisposable Start()
        {
            if (!Util.Util.IsAdministrator())
            {
                Directory.CreateDirectory(_stateDir);
                var jsonPath = Path.Combine(_stateDir, "install.json");
                File.WriteAllText(jsonPath, JsonConvert.SerializeObject(_transaction.Actions.Select(x => x.ToJson())));
                _view.RequestAdmin(jsonPath);

                return _view.OnCancelClicked().Subscribe(_ =>
                {
                    _cancelSource.Cancel();
                    _view.ProcessCancelled();
                    _view.ShowCompletion(true, false);
                });
            }
            else
            {
                return PrivilegedStart();
            }
        }
    }
}