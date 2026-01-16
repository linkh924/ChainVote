<script setup>
import { ref } from 'vue'

const isMenuOpen = ref(false)
const isResultDropdownOpen = ref(false)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const closeMenu = () => {
  isMenuOpen.value = false
  isResultDropdownOpen.value = false
}

const toggleResultDropdown = () => {
  isResultDropdownOpen.value = !isResultDropdownOpen.value
}
</script>

<template>
  <div>
    <div class="navbar">
      <div class="navbar-title">
        <span class="logo-v">V</span><span class="logo-text">ChainVote</span>
      </div>
      <button 
        class="hamburger" 
        :class="{ active: isMenuOpen }"
        @click="toggleMenu">
        <span></span>
        <span></span>
        <span></span>
      </button>
      <div class="menu" :class="{ active: isMenuOpen }">
        <router-link to="/home" class="menu-item" @click="closeMenu">首頁</router-link>
        <router-link to="/info" class="menu-item" @click="closeMenu">資訊</router-link>
        <router-link to="/vote" class="menu-item" @click="closeMenu">投票</router-link>
        <div class="dropdown">
          <button class="menu-item dropdown-btn" @click="toggleResultDropdown">
            ☰ 結果
          </button>
          <div class="dropdown-content" :class="{ show: isResultDropdownOpen }">
            <router-link to="/result?index=1" class="dropdown-item" @click="closeMenu()">結果1</router-link>
            <router-link to="/result?index=2" class="dropdown-item" @click="closeMenu()">結果2</router-link>
            <router-link to="/result?index=3" class="dropdown-item" @click="closeMenu()">結果3</router-link>
            <router-link to="/result?index=4" class="dropdown-item" @click="closeMenu()">結果4</router-link>
            <router-link to="/result?index=5" class="dropdown-item" @click="closeMenu()">結果5</router-link>
            <router-link to="/result?index=6" class="dropdown-item" @click="closeMenu()">結果6</router-link>
            <router-link to="/result?index=7" class="dropdown-item" @click="closeMenu()">結果7</router-link>
            <router-link to="/result?index=8" class="dropdown-item" @click="closeMenu()">結果8</router-link>
            <router-link to="/result?index=9" class="dropdown-item" @click="closeMenu()">結果9</router-link>
            <router-link to="/result?index=10" class="dropdown-item" @click="closeMenu()">結果10</router-link>
          </div>
        </div>
      </div>
      <div class="search">
        <button class="search-btn">🔍</button>
      </div>
    </div>

    <router-view></router-view>
  </div>
</template>

<style scoped>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

.navbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 40px 100px;
    padding: 10px 40px;
    border-radius: 50px;
    background-color: #F4F1F1;
    border: 1px solid #AEAEAE;
}

.navbar-title {
    display: flex;
    align-items: baseline;
    gap: 5px;
}

.logo-v {
    font-size: 28px;
    font-weight: bold;
}

.logo-text {
    font-size: 12px;
}

.menu {
    display: flex;
    gap: 60px;
    align-items: center;
}

.menu-item {
    cursor: pointer;
    font-size: 16px;
    transition: all 0.3s ease;
    padding: 8px 20px;
    border-radius: 20px;
    text-decoration: none;
    color: #333;
    display: inline-block;
}

.menu-item.active,
.menu-item.router-link-active {
    background-color: #F5F5F5;
    border: 1px solid #D2D2D2;
    color: #333;
}

.menu-item:hover {
    color: #333;
    background-color: #E8E8E8;
}

.hamburger {
    display: none;
    flex-direction: column;
    gap: 5px;
    background: none;
    border: none;
    cursor: pointer;
    padding: 8px;
}

.hamburger span {
    width: 25px;
    height: 3px;
    background-color: #333;
    transition: all 0.3s ease;
    border-radius: 2px;
}

.hamburger.active span:nth-child(1) {
    transform: rotate(45deg) translate(8px, 8px);
}

.hamburger.active span:nth-child(2) {
    opacity: 0;
}

.hamburger.active span:nth-child(3) {
    transform: rotate(-45deg) translate(7px, -7px);
}

.search-btn {
    cursor: pointer;
    font-size: 16px;
    padding: 8px 20px;
    border-radius: 20px;
    background-color: #D5D8D5;
    opacity: 0.7;
    transition: opacity 0.3s ease;
    border: none;
}

.search-btn:hover {
    opacity: 1;
}

.dropdown {
    position: relative;
}

.dropdown-btn {
    cursor: pointer;
    background: none;
    border: none;
    color: #333;
}

.dropdown-content {
    position: absolute;
    top: 100%;
    left: 0;
    background-color: white;
    min-width: 180px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.2);
    border-radius: 10px;
    padding: 8px 0;
    z-index: 1000;
    opacity: 0;
    visibility: hidden;
    transform: translateY(-10px);
    transition: all 0.3s ease;
    margin-top: 8px;
}

.dropdown-content.show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.dropdown-item {
    display: block;
    padding: 12px 20px;
    text-decoration: none;
    color: #333;
    transition: background-color 0.2s;
}

.dropdown-item:hover {
    background-color: #F5F5F5;
}

@media (max-width: 1024px) {
    .navbar {
        margin: 40px 100px;
        border-radius: 50px;
    }

    .menu {
        gap: 30px;
    }

    .menu-item {
        font-size: 14px;
        padding: 6px 14px;
    }
}

@media (max-width: 768px) {
    .navbar {
        flex-wrap: nowrap;
        margin: 40px 80px;
        border-radius: 50px;
        gap: 15px;
        position: relative;
    }

    .hamburger {
        display: flex;
        order: 2;
    }

    .navbar-title {
        order: 1;
    }

    .search {
        order: 3;
    }

    .menu {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background-color: #F4F1F1;
        flex-direction: column;
        gap: 0;
        margin-top: 15px;
        border-radius: 20px;
        padding: 10px 0;
        max-height: 0;
        overflow: hidden;
        opacity: 0;
        transition: all 0.3s ease;
        order: 4;
        width: 100%;
        z-index: 1000;
    }

    .menu.active {
        max-height: 300px;
        opacity: 1;
        padding: 15px 0;
    }

    .dropdown {
        width: 100%;
    }

    .dropdown-content {
        position: static;
        box-shadow: none;
        background-color: #E8E8E8;
        margin-top: 0;
        max-height: 0;
        overflow: hidden;
        opacity: 1;
        visibility: visible;
        transform: none;
        transition: max-height 0.3s ease;
    }

    .dropdown-content.show {
        max-height: 500px;
    }

    .dropdown-item {
        padding: 10px 30px;
    }

    .menu-item {
        width: 100%;
        text-align: center;
        padding: 12px 20px;
        border-radius: 0;
    }

    .navbar-title {
        width: auto;
        justify-content: flex-start;
    }

    .search {
        display: none;
    }
}

@media (max-width: 480px) {
    .navbar {
        margin: 20px 5px;
        padding: 5px 20px;
        border-radius: 50px;
    }

    .logo-v {
        font-size: 20px;
    }

    .logo-text {
        font-size: 8px;
    }

    .menu {
        gap: 10px;
    }

    .menu-item {
        font-size: 13px;
        padding: 5px 10px;
    }
}
</style>