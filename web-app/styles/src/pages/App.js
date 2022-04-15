import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Header from "../components/header";
import Footer from "../components/footer";
import Earn from "../pages/earn";
import Dashboard from "../pages/dashboard";
import "./App.scss";

function App() {
  return (
    <Router>
      <Header />
      <div className="container">
        <Routes>
          <Route path="/" element={<Earn />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
