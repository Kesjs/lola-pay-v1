import { useCallback, useEffect, useState } from 'react';
import {
  Activity,
  ArrowDownLeft,
  ArrowUpRight,
  BadgeCheck,
  Banknote,
  BarChart3,
  Bell,
  BookOpenCheck,
  BriefcaseBusiness,
  CheckCircle2,
  ChevronDown,
  CircleAlert,
  CreditCard,
  Gauge,
  Landmark,
  LayoutDashboard,
  LogOut,
  Menu,
  RefreshCw,
  Search,
  Settings2,
  ShieldCheck,
  Users,
  X,
} from 'lucide-react';

type TransactionStatus = 'pending' | 'processing' | 'succeeded' | 'failed';

type Transaction = {
  id: string;
  type: 'recharge';
  network: string;
  amountXof: number;
  feeXof: number;
  status: TransactionStatus;
  reference: string;
  createdAt: string;
};

type Overview = {
  environment: 'sandbox';
  generatedAt: string;
  users: number;
  walletBalanceXof: number;
  volumeXof: number;
  transactionCount: number;
  pendingCount: number;
  failedCount: number;
  transactions: Transaction[];
};

const navigation = [
  { label: "Vue d'ensemble", icon: LayoutDashboard },
  { label: 'Utilisateurs', icon: Users },
  { label: 'Transactions', icon: Activity },
  { label: 'Cartes', icon: CreditCard },
  { label: 'Commerçants', icon: BriefcaseBusiness },
  { label: 'Revenus et frais', icon: BarChart3 },
  { label: 'Rapprochement', icon: BookOpenCheck },
  { label: 'Paramètres', icon: Settings2 },
];

const formatXof = (value: number) =>
  `${new Intl.NumberFormat('fr-FR').format(value)} FCFA`;

const formatDate = (value: string) =>
  new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value));

const statusLabel: Record<TransactionStatus, string> = {
  pending: 'En attente',
  processing: 'En traitement',
  succeeded: 'Réussie',
  failed: 'Échouée',
};

function App() {
  const [activePage, setActivePage] = useState("Vue d'ensemble");
  const [overview, setOverview] = useState<Overview | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const loadOverview = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/admin/overview');
      if (!response.ok) throw new Error('Réponse API invalide');
      setOverview((await response.json()) as Overview);
    } catch {
      setError("L'API sandbox n'est pas joignable. Lance d'abord le backend.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadOverview();
  }, [loadOverview]);

  const selectPage = (label: string) => {
    setActivePage(label);
    setMobileNavOpen(false);
  };

  return (
    <div className="admin-shell">
      <aside className={`sidebar ${mobileNavOpen ? 'is-open' : ''}`}>
        <div className="brand-lockup">
          <div className="brand-mark">lola<span>pay.</span></div>
          <div className="brand-caption">Administration</div>
        </div>
        <div className="sidebar-section-label">Opérations</div>
        <nav aria-label="Navigation principale">
          {navigation.map(({ label, icon: Icon }) => (
            <button
              className={`nav-item ${activePage === label ? 'is-active' : ''}`}
              key={label}
              onClick={() => selectPage(label)}
              type="button"
            >
              <Icon size={17} strokeWidth={1.9} />
              <span>{label}</span>
            </button>
          ))}
        </nav>
        <div className="sidebar-footer">
          <div className="sidebar-status"><span className="status-dot" />API sandbox connectée</div>
          <button className="profile-mini" type="button">
            <span className="avatar">OP</span>
            <span><strong>Opérations</strong><small>Accès interne</small></span>
            <ChevronDown size={15} />
          </button>
        </div>
      </aside>

      {mobileNavOpen && <button className="scrim" onClick={() => setMobileNavOpen(false)} aria-label="Fermer le menu" type="button" />}

      <main className="main-content">
        <header className="topbar">
          <button className="mobile-menu" onClick={() => setMobileNavOpen(true)} aria-label="Ouvrir le menu" type="button"><Menu size={20} /></button>
          <div>
            <p className="breadcrumb">Lola Pay Admin <span>/</span> {activePage}</p>
            <h1>{activePage}</h1>
          </div>
          <div className="topbar-actions">
            <div className="environment-chip"><span />Sandbox</div>
            <button className="icon-button" type="button" aria-label="Notifications"><Bell size={18} /></button>
            <div className="topbar-user"><span className="avatar avatar-light">OP</span><span>Opérations</span><ChevronDown size={15} /></div>
          </div>
        </header>

        <div className="content-wrap">
          <div className="page-intro">
            <div>
              <p className="eyebrow">Suivi en temps réel</p>
              <h2>{activePage === "Vue d'ensemble" ? 'La plateforme, en un regard.' : activePage}</h2>
            </div>
            <button className="secondary-button" type="button" onClick={() => void loadOverview()} disabled={loading}>
              <RefreshCw size={16} className={loading ? 'spin' : ''} /> Actualiser
            </button>
          </div>

          <div className="sandbox-banner"><ShieldCheck size={18} /><span><strong>Environnement sandbox.</strong> Les opérations sont enregistrées dans le ledger de test et n’engagent aucun fonds réel.</span></div>

          {error ? (
            <div className="error-panel"><CircleAlert size={20} /><div><strong>Connexion indisponible</strong><p>{error}</p></div><button className="secondary-button" type="button" onClick={() => void loadOverview()}>Réessayer</button></div>
          ) : activePage === "Vue d'ensemble" ? (
            <Dashboard overview={overview} loading={loading} />
          ) : activePage === 'Transactions' ? (
            <Transactions overview={overview} loading={loading} />
          ) : (
            <EmptyModule label={activePage} />
          )}
        </div>
      </main>
    </div>
  );
}

function Dashboard({ overview, loading }: { overview: Overview | null; loading: boolean }) {
  return (
    <>
      <section className="kpi-grid" aria-label="Indicateurs clés">
        <Kpi icon={Users} label="Utilisateurs actifs" value={loading ? '—' : String(overview?.users ?? 0)} detail="Comptes sandbox" />
        <Kpi icon={Banknote} label="Volume traité" value={loading ? '—' : formatXof(overview?.volumeXof ?? 0)} detail={`${overview?.transactionCount ?? 0} opération(s)`} />
        <Kpi icon={Gauge} label="Solde portefeuille" value={loading ? '—' : formatXof(overview?.walletBalanceXof ?? 0)} detail="Source ledger" />
        <Kpi icon={CircleAlert} label="À surveiller" value={loading ? '—' : String((overview?.pendingCount ?? 0) + (overview?.failedCount ?? 0))} detail="En attente ou échouées" tone="warning" />
      </section>
      <section className="dashboard-grid">
        <div className="panel activity-panel">
          <div className="panel-heading"><div><p className="eyebrow">Ledger sandbox</p><h3>Dernières opérations</h3></div><span className="live-label"><span />Actualisé maintenant</span></div>
          {loading ? <LoadingRows /> : overview?.transactions.length ? <TransactionTable transactions={overview.transactions} compact /> : <EmptyState icon={Activity} title="Aucune opération" body="Crée une recharge depuis l’application mobile pour alimenter ce journal." />}
        </div>
        <div className="panel signal-panel">
          <div className="panel-heading"><div><p className="eyebrow">Contrôles</p><h3>État du système</h3></div><BadgeCheck size={20} className="success-icon" /></div>
          <div className="signal-list">
            <Signal name="API métier" value="Connectée" state="ok" />
            <Signal name="Ledger équilibré" value="Actif" state="ok" />
            <Signal name="Partenaires financiers" value="Désactivés" state="neutral" />
            <Signal name="Rapprochement" value="À configurer" state="neutral" />
          </div>
          <div className="signal-note"><Landmark size={17} /><span>Les intégrations de production seront activées séparément après validation des partenaires.</span></div>
        </div>
      </section>
    </>
  );
}

function Transactions({ overview, loading }: { overview: Overview | null; loading: boolean }) {
  return <section className="panel full-panel"><div className="panel-heading"><div><p className="eyebrow">Journal financier</p><h3>Toutes les transactions</h3></div><div className="table-actions"><label className="search-field"><Search size={16} /><input placeholder="Rechercher une référence" aria-label="Rechercher une référence" /></label><button className="secondary-button" type="button"><ArrowDownLeft size={16} />Exporter</button></div></div>{loading ? <LoadingRows /> : overview?.transactions.length ? <TransactionTable transactions={overview.transactions} /> : <EmptyState icon={Activity} title="Le journal est vide" body="Les opérations créées dans la sandbox apparaîtront ici." />}</section>;
}

function TransactionTable({ transactions, compact = false }: { transactions: Transaction[]; compact?: boolean }) {
  return <div className="table-scroll"><table className={compact ? 'compact-table' : undefined}><thead><tr><th>Référence</th><th>Réseau</th><th>Date</th><th>Montant</th>{!compact && <th>Frais</th>}<th>Statut</th></tr></thead><tbody>{transactions.map((transaction) => <tr key={transaction.id}><td><span className="reference-cell"><span className="type-icon"><ArrowUpRight size={14} /></span><span><strong>{transaction.reference}</strong><small>Recharge</small></span></span></td><td>{transaction.network}</td><td>{formatDate(transaction.createdAt)}</td><td className="numeric">{formatXof(transaction.amountXof)}</td>{!compact && <td className="numeric">{formatXof(transaction.feeXof)}</td>}<td><span className={`status-pill status-${transaction.status}`}>{statusLabel[transaction.status]}</span></td></tr>)}</tbody></table></div>;
}

function Kpi({ icon: Icon, label, value, detail, tone }: { icon: typeof Users; label: string; value: string; detail: string; tone?: 'warning' }) {
  return <div className={`kpi ${tone === 'warning' ? 'kpi-warning' : ''}`}><div className="kpi-top"><span className="kpi-icon"><Icon size={17} /></span><span>{label}</span></div><strong>{value}</strong><small>{detail}</small></div>;
}

function Signal({ name, value, state }: { name: string; value: string; state: 'ok' | 'neutral' }) {
  return <div className="signal-row"><span className={`signal-dot signal-${state}`} /><span>{name}</span><strong>{value}</strong></div>;
}

function LoadingRows() { return <div className="loading-rows"><span /><span /><span /></div>; }

function EmptyState({ icon: Icon, title, body }: { icon: typeof Activity; title: string; body: string }) { return <div className="empty-state"><Icon size={24} /><h4>{title}</h4><p>{body}</p></div>; }

function EmptyModule({ label }: { label: string }) { return <section className="panel module-placeholder"><div className="placeholder-icon"><Settings2 size={22} /></div><h3>{label} arrive dans le prochain slice</h3><p>La navigation est déjà branchée. Cette vue sera connectée au même modèle métier, sans données de démonstration statiques.</p></section>; }

export default App;
