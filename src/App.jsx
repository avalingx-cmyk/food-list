import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import CityView from './pages/CityView'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/city/:cityName" element={<CityView />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
