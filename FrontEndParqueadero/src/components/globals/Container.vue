<template>
  <div id="container">
    <div class="container-menu">
      <appmenu></appmenu>
    </div>
    <div class="container-content">
      <router-view />
    </div>
  </div>
</template>
<script>
import Menu from "./Menu.vue";
export default {
  name: "container",
  components: {
    appmenu: Menu,
  },
  data() {
    return {
      message: "Container",
    };
  },
  methods: {
  },
  beforeCreate(){
      this.$bus.$emit("checkSession", "");
  },
  created() {
  },
};
</script>
<style>
.container-menu {
  width: 270px;
  position: absolute;
  height: 100%;
  border-right: 2px solid;
}
.container-content {
  width: calc(100% - 250px);
  margin-left: auto;
  padding-left: 30px;
  padding-right: 20px;
}
</style>